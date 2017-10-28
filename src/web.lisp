(in-package :cl-user)
(defpackage thethirdofmay.web
  (:use :cl
        :caveman2
        :thethirdofmay.model
        :thethirdofmay.controller
        :thethirdofmay.config
        :thethirdofmay.view
        :thethirdofmay.db
        :datafly
        :split-sequence
        :net.telent.date
        :metatilities
        :sxql)
  (:export :*web* :params))
(in-package :thethirdofmay.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

(defun params (assoc-params &rest keys)
  (labels ((acc-param (_params _keys)
             (cond ((null _keys)   _params)
                   ((atom _params) nil)
                   (t
                    (acc-param (cdr (assoc (car _keys) _params :test #'string=)) (cdr _keys))))))
    (acc-param assoc-params keys)))

;; (defun set-flush (msg)
;;   (setf (response-headers *response*) (append (response-headers *response*) (list :flush msg)))

;;
;; Non-authorized area
;;
(defroute "/" (&key _parsed)
  (render #P"main.html"))

(defroute "/techblog/:id" (&key id)
  (render #P"techblog.html" (find-by-id-from-posts (parse-integer id))))

(defun drafts-with-msg (msg)
  (append (get-posts) (list :msg msg)))

;;
;; Authorized area (tech blog)
;;
(defroute "/admin/techblog/index" (&key _parsed)
  (let ((plist (get-posts)))
    (if plist
        (render #P"admin/drafts.html" plist))))

(defroute ("/admin/techblog/post" :method :GET) (&key _parsed)
  (render #P"admin/draftpost.html"))

(defroute ("/admin/techblog/post" :method :POST) (&key _parsed)
  (let ((caption (params _parsed "blog" "caption"))
        (body    (params _parsed "blog" "body"))
        (date    (params _parsed "blog" "date"))
        (action  (params _parsed "blog" "action")))
    (handler-case
        (cond ((string= action "post")
               (progn
                 (add-post caption date body)
                 (render #P"admin/drafts.html" (drafts-with-msg "POST OK"))))
              ((string= action "preview") (render #P"admin/draftpost.html"))
              (t (render #P"admin/draftpost.html")))
      (invalid-date-error (condition)
        (render #P"admin/draftpost.html" (list :msg "invalid date error ~S" date))))))

(defroute ("/admin/techblog/:id/delete" :method :POST) (&key id)
  (delete-post id)
  (render #P"admin/drafts.html" (drafts-with-msg (format nil "記事: ~D IS DELETED" id))))

(defroute ("/admin/techblog/:id/edit" :method :POST) (&rest _parsed)
  (let* ((_params (getf _parsed :_PARSED))
         (caption (params _params "blog" "caption"))
         (body    (params _params "blog" "body"))
         (date    (params _params "blog" "date"))
         (action  (params _params "blog" "action"))
         (id      (params _params "blog" "id")))
    (handler-case
        (progn
          (update-post id caption body date)
          (render #P"admin/drafts.html" (drafts-with-msg (format nil "記事: ~D is UPDATED" id))))      
      (invalid-date-error (condition)
        (render #P"admin/drafts.html" (drafts-with-msg (format nil "invalid date error ~A" date)))))))
    
(defroute ("/admin/techblog/:id" :method :GET) (&key id)
  (handler-case 
      (render #P"admin/draftedit.html" (find-by-id-from-posts (parse-integer id)))
    (nosuch-article-error (condition)
      (render #P"admin/drafts.html" (list :msg (format nil "no such article id: ~D" id))))))

;;
;; Authorized area (画像アップロード)
;;
(defroute ("/admin/image/upload" :method :GET) (&rest _parsed)
  (render #P"admin/imageuploader.html"))

(defroute ("/admin/image/upload" :method :POST) (&rest _parsed)
  (let ((file (nth 1 (car (getf _parsed :_PARSED))))) ;; これ変な気がするがこうするよりほかない
    (format t "~S~%" (add-new-photo file))
    (render #P"admin/imageuploader.html")))

(defroute ("/admin/image/test" :method :POST) (&rest _parsed)
  (format t "~S~%" _parsed))

;;
;; login
;;

;;
;; Error pages
(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))


(in-package :cl-user)
(defpackage thethirdofmay.web
  (:use :cl
        :caveman2
        :thethirdofmay.controller
        :thethirdofmay.config
        :thethirdofmay.view
        :thethirdofmay.db
        :datafly
        :split-sequence
        :sxql)
  (:export :*web*))
(in-package :thethirdofmay.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)


;; (param '(("test" ("post" . "10") ("body" . "20"))
;;                   ("blog" ("post" . "30") ("body" . "40"))) "blog" "body")
(defun params (assoc-params &rest keys)
  (labels ((acc-param (_params _keys)
             (cond ((null _keys) _params)
                   ((atom _params) nil)
                   (t
                    (acc-param (cdr (assoc (car _keys) _params :test #'string=)) (cdr _keys))))))
    (acc-param assoc-params keys)))
                
(defun foobar (val &rest keys)
  (if (null val)
      val
      (progn
        (format t "~S ~S~%" val keys)
        (foobar (cdr val) (cdr keys)))))

;;
;; Routing rules
(defroute "/" (&key _parsed)
  (format t "~S" _parsed)
;;  (root-index (param "blog" _parsed))
  (render #P"index.html"))

(defroute "/test/*" (&key splat)
  (format nil "<div style='font-size:.8em;'>~{~a<br>~%~}</div>"
          (test)))

(defun foo (&rest values)
  (format t "~a" values))

;;
;; Error pages
(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

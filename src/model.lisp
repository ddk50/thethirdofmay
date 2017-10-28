(in-package :cl-user)
(defpackage thethirdofmay.model
  (:use :cl
        :caveman2
        :thethirdofmay.config
        :thethirdofmay.db
        :datafly
        :net.telent.date
        :metatilities
        :cl-markdown
        :split-sequence
        :sxql)
  (:export :add-post
           :add-new-photo
           :delete-post
           :get-posts
           :find-by-id-from-posts
           :invalid-date-error
           :error-arg-of
           :nosuch-article-error
           :update-post))

(in-package :thethirdofmay.model)

(define-condition invalid-date-error (error)
  ((arg :initarg :arg
        :accessor error-arg-of))
  (:report
   (lambda (condition stream)
     (format nil "~%invalid date format: ~S~%"
             (error-arg-of condition)))))


(define-condition nosuch-article-error (error)
  ((arg :initarg :arg
        :accessor error-arg-of))
  (:report
   (lambda (condition stream)
     (format nil "~%nosuch article: ~S~%"
             (error-arg-of condition)))))

(defmodel (posts (:inflate updated-at #'(lambda (x) (format-date "%Y/%m/%d %H:%M" x)))
                 (:inflate created-at #'(lambda (x) (format-date "%Y/%m/%d %H:%M" x)))
                 (:inflate published #'(lambda (x) (if (string= x "f") nil t))))  
  id
  caption
  body
  compiled-body
  published
  created-at
  updated-at)

(defmodel (photos (:inflate updated-at #'(lambda (x) (format-date "%Y/%m/%d %H:%M" x)))
                  (:inflate created-at #'(lambda (x) (format-date "%Y/%m/%d %H:%M" x)))
                  (:inflate sensitive  #'(lambda (x) (if (string= x "f") nil t))))  
  id
  caption
  comment
  sensitive
  created-at
  updated-at)

(defun compile-md (body)
  (nth-value 1 (markdown:markdown body :stream nil)))

(defun add-post (caption date body)
  (let ((parsed-date (net.telent.date:parse-time date)))
    (if parsed-date
        (with-connection (db)
          (retrieve-all
           (insert-into :posts
                        (set= :caption       caption
                              :body          body
                              :compiled_body (compile-md body)
                              :created_at    parsed-date
                              :updated_at    parsed-date))
           :as 'posts))
        (error (make-condition 'invalid-date-error :arg date)))))

(defun move-image-to-storedir (image-id type from &optional (to thethirdofmay.config:*image-save-directory*))
  (ensure-directories-exist to)
  (let* ((to-filename (make-pathname :name (write-to-string image-id)
                                     :type type))
         (actual-to   (merge-pathnames to-filename to)))    
    (rename-file from actual-to)))

(defun execute-insertsql ()
  (with-connection (db)
    (execute
     (insert-into :photos
                  (set= :caption ""
                        :comment ""
                        :created_at (get-universal-time)
                        :updated_at (get-universal-time))))))

(defun get-last-photoid ()
  (nth 1 (with-connection (db)
           (retrieve-one "select last_insert_rowid() from photos limit 1;"))))

;; (defun add-new-photo (tmpfile-path)  
;;   (with-connection (db)
    
;;     (let ((err t))
;;       (unwind-protect
;;            (let* ((r1    (execute-insertsql))
;;                   (newid (get-last-photoid)))
;;              ;; 写真を移動する
;;              (move-image-to-storedir newid "jpg" tmpfile-path)
             
;;              ;; エラーが起きてない! commitしてもよい
;;              (setf err nil)
;;              newid)
;;         (when err (format t "error in insert with-connection execute rollback"))))))

(defun add-new-photo (tmpfile-path)
  (dbi:with-transaction (db)
    (let* ((r1    (execute-insertsql))
           (newid (get-last-photoid)))
      ;; 写真を移動する
      (move-image-to-storedir newid "jpg" tmpfile-path))))

(defun do-find-by-id-from-posts (id)
  (with-connection (db)
    (let ((ret (retrieve-one
                 (select :*
                         (where (:= :id id))
                         (from :posts))
                 :as 'posts)))
      (if ret
          ret
          (error (make-condition 'nosuch-article-error :arg id))))))

(defun find-by-id-from-posts (id)
  (let ((x (do-find-by-id-from-posts id)))
    (list :id             (posts-id x)
          :caption        (posts-caption x)
          :body           (posts-body x)
          :compiled_body  (posts-compiled-body x)
          :published      (posts-published x)
          :created-at     (posts-created-at x)
          :updated-at     (posts-updated-at x))))

(defun update-post (id caption body date)
  (let ((parsed-date (net.telent.date:parse-time date))
        (parsed-id   (parse-integer id)))
    (if (and parsed-date parsed-id)
        (with-connection (db)
          (execute
           (update :posts
                   (set= :id            parsed-id
                         :updated_at    parsed-date
                         :caption       caption
                         :body          body
                         :compiled_body (compile-md body))
                   (where (:= :id id)))))
        (error (make-condition 'invalid-date-error :arg date)))))

(defun delete-post (id)
  (with-connection (db)
    (retrieve-all
     (delete-from :posts
       (where (:= :id id)))
     :as 'posts)))

(defun do-get-posts ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :posts))
     :as 'posts)))

(defun get-posts ()  
  (list :posts (mapcar #'(lambda (x)
                           (list :id             (posts-id x)
                                 :caption        (posts-caption x)
                                 :body           (posts-body x)
                                 :compiled_body  (posts-compiled-body x)
                                 :published      (posts-published x)
                                 :created-at     (posts-created-at x)
                                 :updated-at     (posts-updated-at x)))
                       (do-get-posts))))

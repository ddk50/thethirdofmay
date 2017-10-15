(in-package :cl-user)
(defpackage thethirdofmay.model
  (:use :cl
        :caveman2
        :thethirdofmay.config
        :thethirdofmay.db
        :datafly
        :net.telent.date
        :metatilities
        :split-sequence
        :sxql)
  (:export :add-post
           :delete-post
           :get-posts
           :find-by-id-from-posts
           :invalid-date-error
           :error-arg-of
           :update-post))

(in-package :thethirdofmay.model)

(define-condition invalid-date-error (error)
  ((arg :initarg :arg
        :accessor error-arg-of))
  (:report
   (lambda (condition stream)
     (format nil "~%invalid date format: ~S~%"
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

(defun add-post (caption date body)
  (let ((parsed-date (net.telent.date:parse-time date)))
    (if parsed-date
        (with-connection (db)
          (retrieve-all
           (insert-into :posts
                        (set= :caption     caption
                              :body        body
                              :created_at  parsed-date
                              :updated_at  parsed-date))
           :as 'posts))
        (error (make-condition 'invalid-date-error :arg date)))))

(defun do-find-by-id-from-posts (id)
  (with-connection (db)
    (retrieve-one
     (select :*
       (where (:= :id id))
       (from :posts))
     :as 'posts)))

(defun find-by-id-from-posts (id)
  (let ((x (do-find-by-id-from-posts id)))    
    (list :id             (posts-id x)
          :caption        (posts-caption x)
          :body           (posts-body x)
          :compiled-body  (posts-compiled-body x)
          :published      (posts-published x)
          :created-at     (posts-created-at x)
          :updated-at     (posts-updated-at x))))

(defun update-post (id caption body date)
  (let ((parsed-date (net.telent.date:parse-time date))
        (parsed-id   (parse-integer id)))
    (if parsed-date
        (with-connection (db)
          (execute
           (update :posts
                   (set= :id         parsed-id
                         :updated_at parsed-date
                         :caption    caption
                         :body       body)
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
                                 :compiled-body  (posts-compiled-body x)
                                 :published      (posts-published x)
                                 :created-at     (posts-created-at x)
                                 :updated-at     (posts-updated-at x)))
                       (do-get-posts))))

(in-package :cl-user)
(defpackage thethirdofmay.controller
  (:use :cl)
  (:export :root-index)
  (:import-from :thethirdofmay.config
                :config))

(in-package :thethirdofmay.controller)

(defun hello-world ()
  "hello world")

(defun root-index (body)
  (format t "~S" body))

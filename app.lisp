(push (truename "/Users/kazushi/repos/thethirdofmay") asdf:*central-registry*)

(ql:quickload :thethirdofmay)

(defpackage thethirdofmay.app
  (:use :cl)
  (:import-from :lack.builder
                :builder)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :thethirdofmay.web
                :*web*)
  (:import-from :thethirdofmay.config
                :config
                :productionp
                :*static-directory*))
(in-package :thethirdofmay.app)

(builder
 (:static
  :path (lambda (path)
          (if (ppcre:scan "^(?:/images/|/css/|/js/|/robot\\.txt$|/favicon\\.ico$)" path)
              path
              nil))
  :root *static-directory*)
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((datafly:*trace-sql* t))
           (funcall app env)))))
 *web*)

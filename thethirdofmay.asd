(in-package :cl-user)
(defpackage thethirdofmay-asd
  (:use :cl :asdf))
(in-package :thethirdofmay-asd)

(defsystem thethirdofmay
  :version "0.1"
  :author "takahashi"
  :license ""
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop
               ;; markdown engine
               :cl-markdown

               ;; for @route annotation
               :cl-syntax-annot

               ;; HTML Template
               :djula

               ;; date parsing
               :net-telent-date               
               :metatilities

               ;; for DB
               :datafly
               :sxql)
  :components ((:module "src"
                :components
                ((:file "model" :depends-on ("config" "db"))
                 (:file "controller" :depends-on ("config" "db"))
                 (:file "techblog_controller" :depends-on ("config" "db"))
                 (:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (load-op thethirdofmay-test))))

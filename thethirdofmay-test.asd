(in-package :cl-user)
(defpackage thethirdofmay-test-asd
  (:use :cl :asdf))
(in-package :thethirdofmay-test-asd)

(defsystem thethirdofmay-test
  :author "takahashi"
  :license ""
  :depends-on (:thethirdofmay
               :prove)
  :components ((:module "t"
                :components
                ((:file "thethirdofmay"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))

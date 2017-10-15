(in-package :cl-user)
(defpackage thethirdofmay-test
  (:use :cl
        :thethirdofmay
        :prove))
(in-package :thethirdofmay-test)

(plan nil)


;; パースできる
(is (param '(("test" ("post" . "10") ("body" . "20"))
             ("blog" ("post" . "30") ("body" . "40"))) "blog" "body") 40)

(finalize)

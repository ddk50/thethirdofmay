(in-package :cl-user)
(defpackage thethirdofmay.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :*image-save-directory*
           :appenv
           :developmentp
           :productionp))
(in-package :thethirdofmay.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*   (asdf:system-source-directory :thethirdofmay))
(defparameter *static-directory*   (merge-pathnames #P"static/" *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/" *application-root*))

(defconfig :common
  `(:databases ((:maindb :sqlite3 :database-name ":memory:"))))

(defconfig |development|
  `(:debug T
    :databases ((:maindb :sqlite3 :database-name ,(merge-pathnames #P"development.db" *application-root*)))))

(defconfig |production|
  `(:debug T
    :databases ((:maindb :sqlite3 :database-name ,(merge-pathnames #P"production.db" *application-root*)))))

(defconfig |test|
  `(:debug T
    :databases ((:maindb :sqlite3 :database-name ,(merge-pathnames #P"test.db" *application-root*)))))


(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))


;;
;; アップロードしたファイルをどこに保存するか
;; 最後にかならず（スラッシュを付けること)
;;
(defparameter *image-save-directory* #P"/var/thethirdofmay/images/")


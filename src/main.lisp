(in-package :cl-user)
(defpackage thethirdofmay
  (:use :cl)
  (:import-from :thethirdofmay.config
                :config)
  (:import-from :clack
                :clackup)
  (:export :start
           :stop))
(in-package :thethirdofmay)
(defvar *appfile-path*
  (asdf:system-relative-pathname :thethirdofmay #P"app.lisp"))

(defvar *handler* nil)

;; clack側からやってくるアップロードしたファイルは
;; 常にディスクに書かれるようにするため、リミットを0とする
;; TODO まあ、ディスクメモリと使い分けてもいいのではないか？
(setf smart-buffer:*default-memory-limit* 0)

(defun start (&rest args &key server port debug &allow-other-keys)
  (declare (ignore server port debug))
  (when *handler*
    (restart-case (error "Server is already running.")
      (restart-server ()
        :report "Restart the server"
        (stop))))
  (setf *handler*
        (apply #'clackup *appfile-path* args)))

(defun stop ()
  (prog1
      (clack:stop *handler*)
    (setf *handler* nil)))

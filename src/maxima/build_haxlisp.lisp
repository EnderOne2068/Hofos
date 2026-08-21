;;;; build_haxlisp.lisp -- build the SBCL core that haxMac embeds for :lisp interop.
;;;;   sbcl --core /usr/lib/sbcl/sbcl.core --non-interactive \
;;;;        --no-sysinit --no-userinit --load build_haxlisp.lisp
;;;; Exposes ONE C-callable entry, hax_lisp_eval, that reads+evaluates a Common
;;;; Lisp form from a string and returns its printed value (or an error string).

(in-package :cl-user)

(sb-alien:define-alien-callable ("hax_lisp_eval" hax-lisp-eval)
    sb-alien:c-string ((input sb-alien:c-string))
  (handler-case
      (let ((*package* (find-package :cl-user)))
        (prin1-to-string (eval (read-from-string input))))
    (error (e) (format nil "lisp-error: ~a" e))))

(sb-ext:save-lisp-and-die "haxlisp.core" :callable-exports '(hax-lisp-eval))

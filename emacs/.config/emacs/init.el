(setq native-comp-speed 3)
(setq native-comp-async-report-warnings-errors 'silent)

(auto-save-mode nil)
(setq c-basic-offset 4)
(setq c-guess-guessed-basic-offset 4)
(setq c-ts-mode-indent-offset 4)
(setq c++-ts-mode-indent-offset 4)
(setq c++-ts-mode-basic-offet 4)
(setq c-ts-mode-indent-offset 4)

;; (set-frame-font "DejaVu Sans Mono 28")
(menu-bar-mode -1)
(blink-cursor-mode 0)
;; (cua-mode)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(winner-mode 1)
(global-hl-line-mode)
(global-tab-line-mode)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq initial-buffer-choice nil)

(setq make-backup-files nil)

(setq-default mode-line-format
      '("%e"
        mode-line-front-space
        ;; mode-line-mule-info -- I'm always on utf-8
        mode-line-client
        mode-line-modified
        ;; mode-line-remote -- no need to indicate this specially
        ;; mode-line-frame-identification -- this is for text-mode emacs only
        " "
        mode-line-directory
        mode-line-buffer-identification
        " "
        mode-line-position
        ;;(vc-mode vc-mode)  -- I use magit, not vc-mode
        (flycheck-mode flycheck-mode-line)
        " "
        mode-line-modes
        mode-line-misc-info
        mode-line-end-spaces))

(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)

    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))


(elpaca elpaca-use-package
	(elpaca-use-package-mode))

(use-package company
  :ensure t
  :init (global-company-mode +1))

;; (use-package devil
;;  :ensure t
;;  :config
;;  (global-devil-mode)
;;  (global-set-key (kbd "C--") 'global-devil-mode)
;;  (devil-set-key (kbd "-")
;;  ))

(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)
(setq company-selection-wrap-around t)

(setq treesit-language-source-alist
      '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
	(c "https://github.com/tree-sitter/tree-sitter-c")
	(cmake "https://github.com/uyha/tree-sitter-cmake")))

(use-package clang-format :ensure t)
(defun clang-format-save-hook()
  "Create a buffer local save hook to apply `clang-format-buffer'"
  ;; Only format if .clang-format is found
  (when (locate-dominating-file "." ".clang-format")
    (clang-format-buffer))
  ;; Continue to save
  nil)

(define-minor-mode clang-format-on-save-mode
  "Buffer-local mode to enable/disable automated clang format on save"
  :lighter " ClangFormat"
  (if clang-format-on-save-mode
      (add-hook 'before-save-hook 'clang-format-save-hook nil t)
    (remove-hook 'before-save-hook 'clang-format-save-hook t)))

;; Create a globalized minor mode to
;;   - Auto enable the above mode only for C/C++, or glsl in your case
;;   - Be able to turn it off globally if needed
(define-globalized-minor-mode clang-format-auto-enable-mode clang-format-on-save-mode
  (lambda()(clang-format-on-save-mode t))
  :predicate '(c-mode c++-mode c-or-c++-mode c-ts-base-mode c-ts-mode c++-ts-mode))
(clang-format-auto-enable-mode t)

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :custom (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))

(use-package cmake-mode
   :defer t
   :ensure t)
 
;;  (use-package company-cmake
;;    :after cmake-mode
;;    :defer t
;;    :ensure 	(:build t
;;  		  :host github))

(dolist (lang treesit-language-source-alist)
  (unless (treesit-language-available-p (car lang))
    (treesit-install-language-grammar (car lang))))

(setq treesit-load-name-override-list
      '((c++ "libtree-sitter-cpp")))

(add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
(add-to-list 'major-mode-remap-alist
             '(c-or-c++-mode . c-or-c++-ts-mode))


;; (add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
;; (add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-ts-mode))

(setq hscroll-margin 2
      hscroll-step 1
      scroll-conservatively 101
      scroll-margin 0
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2)
(delete-selection-mode +1)
(setq create-lockfiles nil)

(use-package combobulate
  :defer t
  :ensure (combobulate :host github :repo "mickeynp/combobulate")
  :preface
  (setq combobulate-key-prefix "C-c o")
)

(use-package emacs
  :hook (c++-ts-mode . eglot-ensure)
  :hook (c-ts-mode . eglot-ensure)
  :hook (cmake-ts-mode . eglot-ensure))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(transient-mark-mode 1)
;; (electric-indent-mode -1)

(setq evil-vsplit-window-right t)

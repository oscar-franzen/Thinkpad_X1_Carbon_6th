(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults                 ;; Set up some better Emacs defaults
    material-theme                  ;; Theme
    gruvbox-theme
    gandalf-theme
;    eval-in-repl
    elpy                            ;; Emacs Lisp Python Environment
    fill-column-indicator
    )
  )

(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#212121" "#B71C1C" "#558b2f" "#FFA000" "#2196f3" "#4527A0" "#00796b" "#FAFAFA"))
 '(custom-enabled-themes (quote (deeper-blue)))
 '(custom-safe-themes
   (quote
    ("585942bb24cab2d4b2f74977ac3ba6ddbd888e3776b9d2f993c5704aa8bb4739" "a24c5b3c12d147da6cef80938dca1223b7c7f70f2f382b26308eba014dc4833a" "732b807b0543855541743429c9979ebfb363e27ec91e82f463c91e68c772f6e3" "1436d643b98844555d56c59c74004eb158dc85fc55d2e7205f8d9b8c860e177f" "8e797edd9fa9afec181efbfeeebf96aeafbd11b69c4c85fa229bb5b9f7f7e66c" "2b9dc43b786e36f68a9fd4b36dd050509a0e32fe3b0a803310661edb7402b8b6" "b583823b9ee1573074e7cbfd63623fe844030d911e9279a7c8a5d16de7df0ed0" "a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0" "e6ccd0cc810aa6458391e95e4874942875252cd0342efd5a193de92bfbb6416b" default)))
 '(fci-rule-color "#ECEFF1")
 '(hl-sexp-background-color "#efebe9")
 '(package-selected-packages
   (quote
    (smooth-scrolling sphinx-doc python-docstring phpcbf php-mode js-auto-beautify multi-web-mode py-autopep8 multi-line highlight-indent-guides ace-window ess-R-data-view pylint material-theme better-defaults)))
 '(pdf-view-midnight-colors (quote ("#282828" . "#f2e5bc")))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#B71C1C")
     (40 . "#FF5722")
     (60 . "#FFA000")
     (80 . "#558b2f")
     (100 . "#00796b")
     (120 . "#2196f3")
     (140 . "#4527A0")
     (160 . "#B71C1C")
     (180 . "#FF5722")
     (200 . "#FFA000")
     (220 . "#558b2f")
     (240 . "#00796b")
     (260 . "#2196f3")
     (280 . "#4527A0")
     (300 . "#B71C1C")
     (320 . "#FF5722")
     (340 . "#FFA000")
     (360 . "#558b2f"))))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "darkgreen" :foreground "white"))))
 '(mode-line-inactive ((t (:background nil)))))

(setq inhibit-startup-message t)    ;; Hide the startup message
;(load-theme 'modus-operandi t)            ;; Load material theme
(global-linum-mode t)               ;; Enable line numbers globally
;(elpy-enable)
(require 'ido)
(ido-mode t)

(require 'fill-column-indicator)
(setq-default fci-rule-column 80)
(define-globalized-minor-mode
 global-fci-mode fci-mode (lambda () (fci-mode 1)))
(global-fci-mode t)
(setq python-shell-interpreter "python3")
(setq linum-format "%d ")
;(desktop-save-mode 1)

(setq scroll-step            1
      scroll-conservatively  10000)


;(cua-mode t)
;(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
;(transient-mark-mode 1) ;; No region when it is not highlighted
;(setq cua-keep-region-after-copy t) ;; Standard Windows behaviour


;(setq x-select-enable-clipboard t)
;(setq x-select-enable-primary nil)
(setq make-backup-files nil)

;; stop creating those #auto-save# files
(setq auto-save-default nil)

(global-hl-line-mode 1)
;; underline the current line
;(set-face-attribute hl-line-face nil :underline t)

(show-paren-mode 1)

(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

(add-hook 'org-mode-hook '(lambda () (setq fill-column 80)))
(add-hook 'org-mode-hook 'auto-fill-mode)


;(set-face-attribute 'default nil
;                  :font "DejaVu Sans Mono-10")

(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)
(setq highlight-indent-guides-character ?\|)
;(set-default-font "-*-terminus-medium-*-*-*-*-70-*-*-*-*-*-*")
(set-default-font "-misc-fixed-medium-r-semicondensed--13-*-*-*-c-60-iso8859-1")
(setq default-frame-alist '((font . "-misc-fixed-medium-r-semicondensed--13-*-*-*-c-60-iso8859-1")))
(add-to-list 'default-frame-alist '(font . "-misc-fixed-medium-r-semicondensed--13-*-*-*-c-60-iso8859-1"))

;(global-whitespace-mode 1)

(server-start)

(defun undo-all ()
  "Undo all edits."
  (interactive)
  (when (listp pending-undo-list)
    (undo))
  (while (listp pending-undo-list)
    (undo-more 1))
  (message "Buffer was completely undone"))

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-enable-current-element-highlight t)
(setq web-mode-markup-indent-offset 2)

    (add-hook 'html-mode-hook
        (lambda ()
          ;; Default indentation is usually 2 spaces
          (set (make-local-variable 'sgml-basic-offset) 2)))

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "C-d") 'duplicate-line)

(defun my-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (delete-region
   (point)
   (progn
     (forward-word arg)
     (point))))

(defun my-backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
  (interactive "p")
  (my-delete-word (- arg)))

(defun my-delete-line ()
  "Delete text from current position to end of line char.
This command does not push text to `kill-ring'."
  (interactive)
  (delete-region
   (point)
   (progn (end-of-line 1) (point)))
  (delete-char 1))

(defun my-delete-line-backward ()
  "Delete text between the beginning of the line to the cursor position.
This command does not push text to `kill-ring'."
  (interactive)
  (let (p1 p2)
    (setq p1 (point))
    (beginning-of-line 1)
    (setq p2 (point))
    (delete-region p1 p2)))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

; bind them to emacs's default shortcut keys:
(global-set-key (kbd "C-S-k") 'my-delete-line-backward) ; Ctrl+Shift+k
(global-set-key (kbd "C-k") 'my-delete-line)
(global-set-key (kbd "M-d") 'my-delete-word)
(global-set-key (kbd "<M-backspace>") 'backward-delete-word)

;(setq inhibit-startup-screen t)

(setq warning-minimum-level :emergency)

(add-hook 'smooth-scroll 'smooth-scroll-mode)
; https://www.emacswiki.org/emacs/SmoothScrolling#toc2
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time

; prevent comments from being indented
; https://stackoverflow.com/questions/780796/emacs-ess-mode-tabbing-for-comment-region
(setq ess-indent-with-fancy-comments nil)
(require 'ess)

; https://github.com/abo-abo/ace-window
; When there are two windows, ace-window will call other-window
; (unless aw-dispatch-always is set non-nil). If there are more, each
; window will have the first character of its window label highlighted
; at the upper left of the window.
(global-set-key (kbd "C-x o") 'ace-window)
;(global-set-key (kbd "M-p") 'ace-window)

; show file path in title
(setq-default frame-title-format '("%f"))

(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (load-theme 'misterioso)))

(add-hook 'window-setup-hook 'on-after-init)

(set-face-attribute 'mode-line-buffer-id nil :foreground "white")

(setq web-mode-engines-alist '(("php" . "\\.html\\'")))

(tool-bar-mode -1)
(menu-bar-mode -1)

(set-cursor-color "#5D8AA8")

; prevent opening "help" when accidentally pressing C-backspace
(global-set-key (kbd "C-h") 'delete-backward-char)

(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key [(meta shift up)]  'move-line-up)
(global-set-key [(meta shift down)]  'move-line-down)

(setq-default c-basic-offset 4)
(global-linum-mode t)               ;; Enable line numbers globally

(setq scroll-step            1
      scroll-conservatively  10000)

(setq x-select-enable-primary nil)

(global-hl-line-mode 1)
;; underline the current line
;(set-face-attribute hl-line-face nil :underline t)

(show-paren-mode 1)

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
  )

(global-set-key (kbd "C-d") 'duplicate-line)

(add-hook 'smooth-scroll 'smooth-scroll-mode)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time

(set-face-attribute 'mode-line-buffer-id nil :foreground "white")

(column-number-mode 1)
(size-indication-mode 1)

(add-hook 'org-mode-hook 'org-indent-mode)

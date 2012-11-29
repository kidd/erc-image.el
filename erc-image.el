;;; erc-image.el --- Show received image urls in the ERC buffer

;; Copyright (C) 2012  Jon de Andrés Frías
;; Copyright (C) 2012  Raimon Grau Cuscó
;; Copyright (C) 2012  David Vázquez

;; Author: Jon de Andrés Frías <jondeandres@gmail.com>
;; Author: Raimon Grau Cuscó <raimonster@gmail.com>
;; Keywords: multimedia

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Show inlined images (png/jpg) in erc buffers.
;;;
;;; This plugin subscribes to hooks `erc-insert-modify-hook' and
;;; `erc-send-modify-hook' to download and show images. In this early
;;; version it's doing this synchronously.


;;; Code:
(require 'erc)

(defgroup erc-image nil
  "Enable image."
  :group 'erc)

(defcustom erc-image-regex "\\.png$\\|\\.jpg$\\|\\.jpeg$"
  "Regex to mach URLs to be downloaded"
  :group 'erc-image
  :type '(regexp :tag "Regex"))

(defun erc-image-show-url-image ()
  (interactive)
  (goto-char (point-min))
  (search-forward "http" nil t)
  (let ((url (thing-at-point 'url))
        (file-name))
    (when (and url (string-match erc-image-regex url))
      (setq file-name (concat "/tmp/" (md5 url)))
      (goto-char (point-max))
      (url-retrieve url
                    (lambda  (status file-name marker)
                      (goto-char (point-min))
                      (search-forward "\n\n")
                      (write-region (point) (point-max) file-name)
                      (with-current-buffer (marker-buffer marker)
                        (save-excursion
                          (let ((inhibit-read-only t))
                            (goto-char (marker-position marker))
                            (insert-before-markers
                             (propertize " " 'display (create-image file-name))
                             "\n")
                            (put-text-property (point-min) (point-max) 'read-only t)))))
                    (list
                     file-name
                     (point-marker))
                    t))))

(define-erc-module image nil
  "Display inlined images in ERC buffer"
  ((add-hook 'erc-insert-modify-hook 'erc-image-show-url-image t)
   (add-hook 'erc-send-modify-hook 'erc-image-show-url-image t))
  ((remove-hook 'erc-insert-modify-hook 'erc-image-show-url-image)
   (remove-hook 'erc-send-modify-hook 'erc-image-show-url-image))
  t)

(provide 'erc-image)
;;; erc-image.el ends here

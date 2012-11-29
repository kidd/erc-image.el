# erc-image.el #

Show inlined images (png/jpg) in erc buffers.

usage:

```lisp
(require 'erc-image)
(add-to-list 'erc-modules 'image)
(erc-update-modules)
```

Or `(require 'erc-image)` and  `M-x customize-option erc-modules RET`

This plugin subscribes to hooks `erc-insert-modify-hook` and
`erc-send-modify-hook` to download and show images.
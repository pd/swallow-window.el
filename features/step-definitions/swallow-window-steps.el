(Before
 (setq sw/current-layout nil
       sw/current-windows nil)
 (dolist (buf (buffer-list))
   (when (s-matches? "^sw/" (buffer-name buf))
     (kill-buffer buf))))

(defun sw/window-named (name)
  (cdr (assoc name sw/current-windows)))

(Given "^I delete all other windows$"
       (lambda () (delete-other-windows)))

(Given "^the window layout:$"
       (lambda (layout)
         (setq sw/current-layout  (sw/read-layout layout)
               sw/current-windows (sw/mk-layout sw/current-layout))
         (should (= (length (window-list))
                    (sw/win-count sw/current-layout)))))

(When "^I swallow-window \\(.+\\)$"
       (lambda (dir) (swallow-window (intern dir))))

(When "^I select window \\([A-Z]\\)$"
       (lambda (name)
         (select-window (sw/window-named name))))

(Then "^window \\([A-Z]\\) should be the only window in the frame$"
       (lambda (name)
         (should (equal (window-list) (list (sw/window-named name))))))

(Then "^window \\([A-Z]\\) should be deleted$"
       (lambda (name)
         (let ((win (sw/window-named name)))
           (should (not (window-live-p win))))))

(And "^window \\([A-Z]\\) should be the only window on the \\(.+\\)$"
       (lambda (name side)
         (let ((win (sw/window-named name))
               (dirs (cond
                      ((string= "top" side) '(up left right))
                      ((string= "bottom" side) '(down left right))
                      ((string= "left" side) '(up down right))
                      ((string= "right" side) '(up down left)))))
           (select-window win)
           (dolist (dir dirs)
             (unless (window-minibuffer-p (windmove-find-other-window dir))
               (should-not (windmove-find-other-window dir)))))))

;; for sw/read-layout
(When "^I read the window layout:$"
      (lambda (layout)
        (setq sw/current-layout (sw/read-layout layout))))

(Then "^the layout should be \\(.+\\)$"
      (lambda (expected)
        (should (equal sw/current-layout (read expected)))))
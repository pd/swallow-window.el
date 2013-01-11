;;; swallow-window.el --- Grow the current window into the space occupied by neighboring windows

;; Copyright (C) 2013  Kyle Hargraves

;; Author: Kyle Hargraves <pd@krh.me>
;; URL: https://github.com/pd/swallow-window.el
;; Version: 0.1
;; Keywords: convenience, frames

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

;; Ever have your windows arranged in, say, a 2x2 square and go to delete
;; one of them, only to end up with the wrong window split disappearing?
;; It happens to me all the time. When you use `delete-window', the split
;; that will disappear depends on the order in which you created the
;; windows.
;;
;;     +-------+-------+
;;     |       |       |
;;     |   A   |   B   |
;;     |       |       |
;;     +-------+-------+
;;     |       |       |
;;     |   C*  |   D   |
;;     |       |       |
;;     +-------+-------+
;;
;; Imagine you are focused in window C, which contains tall content such
;; as a rapidly scrolling log file you're tailing. It'd be nice to eliminate
;; window A so that you could see more at once. Unfortunately, you actually
;; opened these in the order (A C D B), so when you kill A, B takes over
;; all of its space.
;;
;; This library fixes that.
;;
;; Rather than deleting window A, stay focused on C and tell it to consume
;; all the space in the window above it.
;;
;;     +-------+-------+      +-------+-------+
;;     |       |       |      |       |       |
;;     |   A   |   B   |      |       |   B   |
;;     |       |       |      |       |       |
;;     +-------+-------+  ->  |   C*  +-------+
;;     |       |       |      |       |       |
;;     |   C*  |   D   |      |       |   D   |
;;     |       |       |      |       |       |
;;     +-------+-------+      +-------+-------+
;;
;; But what if multiple windows were above it?
;;
;;     +-------+-------+      +-------+-------+      +-------+-------+
;;     |   A   |       |      |   A   |       |      |       |       |
;;     +-------+   B   |      +-------+   B   |      |       |   B   |
;;     |   E   |       |      |       |       |      |       |       |
;;     +-------+-------+  ->  |       +-------+  ->  |   C*  +-------+
;;     |       |       |      |   C*  |       |      |       |       |
;;     |   C*  |   D   |      |       |   D   |      |       |   D   |
;;     |       |       |      |       |       |      |       |       |
;;     +-------+-------+      +-------+-------+      +-------+-------+
;;
;; The same operation would first eliminate E, and running it once more
;; would eliminate A.
;;
;; What about a pair of windows split in the opposite direction as the
;; window you are focused on?
;;
;;     +---+---+-------+      +-------+-------+
;;     |   |   |       |      |       |       |
;;     | A | E |   B   |      |       |   B   |
;;     |   |   |       |      |       |       |
;;     +---+---+-------+  ->  |   C*  +-------+
;;     |       |       |      |       |       |
;;     |   C*  |   D   |      |       |   D   |
;;     |       |       |      |       |       |
;;     +-------+-------+      +-------+-------+
;;
;; Some cases are harder to decide:
;;
;;     +-------+-------+      +-------+-------+    +-------+-------+
;;     |   A*  |       |      |       A*      |    |       A*      |
;;     +-------|   C   |  ->  +---------------| OR +---------------|
;;     |   B   |       |      |   B   |   C   |    |       B       |
;;     +-------+-------+      +-------+-------+    +-------+-------+
;;
;; If I swallow right from A, I generally want to retain C; if I had
;; wanted both A and B to grow, I could have just deleted C. So that
;; is the default behavior. With `prefix-arg', though, swallowing will
;; delete C rather than resize it.

;;; Code:

(require 'windmove)

(defun swallow-window (dir)
  (if (one-window-p)
      (message "swallow-window: no other window to swallow")
    (let ((win (windmove-find-other-window dir)))
      (when win (delete-window win)))))

(provide 'swallow-window)
;;; swallow-window.el ends here
;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Thomas Danckaert <post@thomasdanckaert.be>
;;; Copyright © 2018 Meiyo Peng <meiyo.peng@gmail.com>
;;; Copyright © 2019 Marius Bakke <mbakke@fastmail.com>
;;; Copyright © 2017, 2019, 2020 Hartmut Goebel <h.goebel@crazy-compilers.com>
;;; Copyright © 2019 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2020 Zheng Junjie <873216071@qq.com>
;;; Copyright © 2022 Brendan Tildesley <mail@brendan.scot>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages kde-plasma)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system qt)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg))

(define-public breeze
  (package
    (name "breeze")
    (version "5.23.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kde/stable/plasma/" version "/"
                                  name "-" version ".tar.xz"))
              (sha256
               (base32
                "1pyw7rhzkbd9kwsm8l7iz867jhwlbmkarc5iihg0bkbcg1ds18ic"))))
    (build-system qt-build-system)
    ;; TODO: Warning at /gnu/store/…-kpackage-5.34.0/…/KF5PackageMacros.cmake:
    ;;   warnings during generation of metainfo for org.kde.breezedark.desktop:
    ;;   Package type "Plasma/LookAndFeel" not found
    ;; TODO: Check whether is makes sence splitting into several outputs, like
    ;; Debian does:
    ;; - breeze-cursor-theme
    ;; - "out", "devel"
    ;; - kde-style-breeze - Widget style
    ;; - kde-style-breeze-qt4 - propably not useful
    ;; - kwin-style-breeze
    ;; - qml-module-qtquick-controls-styles-breeze - QtQuick style
    (native-inputs
     (list extra-cmake-modules pkg-config))
    (inputs
     (list kcmutils ; optional
           kconfigwidgets
           kcoreaddons
           kde-frameworkintegration ; optional
           kdecoration
           kguiaddons
           ki18n
           kiconthemes ; for optional kde-frameworkintegration
           kpackage
           kwayland ; optional
           kwindowsystem
           qtbase-5
           qtdeclarative ; optional
           qtx11extras))
    (home-page "https://invent.kde.org/plasma/breeze")
    (synopsis "Default KDE Plasma theme")
    (description "Artwork, styles and assets for the Breeze visual style for
the Plasma Desktop.  Breeze is the default theme for the KDE Plasma desktop.")
    (license license:gpl2+)))

(define-public kdecoration
  (package
    (name "kdecoration")
    (version "5.23.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kde/stable/plasma/" version
                                  "/kdecoration-" version ".tar.xz"))
              (sha256
               (base32
                "1kqj8l95wy46kfsw3f1crxwba9zwdlbgi7345mamhyks74wj1628"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list ki18n qtbase-5))
    (home-page "https://invent.kde.org/plasma/kdecoration")
    (synopsis "Plugin based library to create window decorations")
    (description "KDecoration is a library to create window decorations.
These window decorations can be used by for example an X11 based window
manager which re-parents a Client window to a window decoration frame.")
    (license license:lgpl3+)))

(define-public ksshaskpass
  (package
    (name "ksshaskpass")
    (version "5.23.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kde/stable/plasma/" version
                                  "/ksshaskpass-" version ".tar.xz"))
              (sha256
               (base32
                "0p8aka60mc8p96v3bx954jy99n9lf0a4b09sig307clwinfr23if"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
    (inputs
     (list kcoreaddons ki18n kwallet kwidgetsaddons qtbase-5))
    (home-page "https://invent.kde.org/plasma/ksshaskpass")
    (synopsis "Front-end for ssh-add using kwallet")
    (description "Ksshaskpass is a front-end for @code{ssh-add} which stores the
password of the ssh key in KWallet.  Ksshaskpass is not meant to be executed
directly, you need to tell @code{ssh-add} about it.  @code{ssh-add} will then
call it if it is not associated to a terminal.")
    (license license:gpl2+)))

(define-public layer-shell-qt
  (package
    (name "layer-shell-qt")
    (version "5.23.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kde/stable/plasma/" version
                                  "/layer-shell-qt-" version ".tar.xz"))
              (sha256
               (base32
                "1ah66z9hiricw6h3j7x2k7d49y7g4l2s9w2658wjrava2qng9bsr"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules pkg-config))
    (inputs
     (list libxkbcommon
           qtbase-5
           qtdeclarative
           qtwayland
           wayland
           wayland-protocols))
    (home-page "https://invent.kde.org/plasma/layer-shell-qt")
    (synopsis "Qt component for the Wayland ql-layer-shell protocol")
    (description "Qt component for the Wayland ql-layer-shell protocol.")
    (license license:gpl2+)))

(define-public kscreenlocker
  (package
    (name "kscreenlocker")
    (version "5.23.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://kde/stable/plasma/" version
                                  "/kscreenlocker-" version ".tar.xz"))
              (sha256
               (base32
                "07vhwvcyz9ynjzh44zny1f6di2knzy3fkiji3bhrki8p3zc9vjpm"))))
    (build-system qt-build-system)
    (arguments
     `(#:tests? #f ;; TODO: make tests pass
       #:phases
       (modify-phases %standard-phases
         (add-before 'check 'check-setup
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (system "Xvfb :1 -screen 0 640x480x24 &")
             (setenv "DISPLAY" ":1")
             #t))
         (delete 'check)
         ;; Tests use the installed library and require a DBus session.
         (add-after 'install 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (if tests?
                 (begin
                   (setenv "CTEST_OUTPUT_ON_FAILURE" "1")
                   (invoke "dbus-launch" "ctest")))
             #t)))))
    (native-inputs
     (list extra-cmake-modules pkg-config
           ;; For tests.
           dbus xorg-server-for-tests))
    (inputs
     (list kcmutils
           kcrash
           kdeclarative
           kglobalaccel
           ki18n
           kidletime
           knotifications
           ktextwidgets
           kwayland
           kwindowsystem
           kxmlgui
           layer-shell-qt
           libseccomp ;for sandboxing the look'n'feel package
           libxcursor ;missing in CMakeList.txt
           libxi ;XInput, required for grabbing XInput2 devices
           linux-pam
           elogind ;optional loginctl support
           qtbase-5
           qtdeclarative
           qtx11extras
           solid
           wayland
           xcb-util-keysyms))
    (home-page "https://invent.kde.org/plasma/kscreenlocker")
    (synopsis "Screen locking library")
    (description
     "@code{kscreenlocker} is a library for creating secure lock screens.")
    (license license:gpl2+)))

(define-public libkscreen
  (package
    (name "libkscreen")
    (version "5.23.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/plasma/" version "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32 "08wgg96clp685fl5lflrfd4kmf5c2p5ms7n1q2izvg0n6qr37m1i"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules
           ;; For testing.
           dbus))
    (inputs
     (list kwayland libxrandr plasma-wayland-protocols
           qtbase-5 qtwayland wayland qtx11extras))
    (arguments
     '(#:tests? #f)) ; FIXME: 55% tests passed, 5 tests failed out of 11
    (home-page "https://community.kde.org/Solid/Projects/ScreenManagement")
    (synopsis "KDE's screen management software")
    (description "KScreen is the new screen management software for KDE Plasma
Workspaces which tries to be as magic and automatic as possible for users with
basic needs and easy to configure for those who want special setups.")
    (license license:gpl2+)))

(define-public libksysguard
  (package
    (name "libksysguard")
    (version "5.23.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/plasma/" version
                           "/libksysguard-" version ".tar.xz"))
       (sha256
        (base32 "1gy1grkkz7vwglby52vv4gr8zbzsv8rbvwbp6rqvvhmqg7ascc1h"))))
    (native-inputs
     (list extra-cmake-modules pkg-config qttools))
    (inputs
     (list kauth
           kcompletion
           kconfig
           kconfigwidgets
           kcoreaddons
           kdeclarative
           kglobalaccel
           ki18n
           kiconthemes
           kio
           knewstuff
           kservice
           kwidgetsaddons
           kwindowsystem
           libnl
           libcap
           libpcap
           `(,lm-sensors "lib")
           plasma-framework
           qtbase-5
           qtdeclarative
           qtscript
           qtwebchannel
           qtwebengine
           qtwebkit
           qtx11extras
           zlib))
    (build-system qt-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     ;; TODO: Fix this failing test-case
                     (invoke "ctest" "-E" "processtest")))))))
    (home-page "https://userbase.kde.org/KSysGuard")
    (synopsis "Network enabled task and system monitoring")
    (description "KSysGuard can obtain information on system load and
manage running processes.  It obtains this information by interacting
with a ksysguardd daemon, which may also run on a remote system.")
    (license license:gpl3+)))


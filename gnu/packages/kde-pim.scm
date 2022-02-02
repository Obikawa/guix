;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2017, 2019, 2020 Hartmut Goebel <h.goebel@crazy-compilers.com>
;;; Copyright © 2020 Marius Bakke <marius@gnu.org>
;;; Copyright © 2021 Efraim Flashner <efraim@flashner.co.il>
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

(define-module (gnu packages kde-pim)
  #:use-module (guix build-system qt)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages cyrus-sasl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages kde)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages openldap)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages search)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages xml))

(define-public akonadi
  (package
    (name "akonadi")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-" version ".tar.xz"))
       (sha256
        (base32 "1i1q8zda3hl564w02478wyqv35wj8npkqayy7b13shkq9b9j3nj8"))
       (patches (search-patches
                 "akonadi-paths.patch"
                 "akonadi-timestamps.patch"
                 "akonadi-not-relocatable.patch"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools shared-mime-info))
    (inputs
     (list boost
           kconfig
           kconfigwidgets
           kcoreaddons
           kcrash
           ki18n
           kiconthemes
           kio
           kitemmodels
           kitemviews
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libxml2
           libxslt
           ;; Do NOT add mysql or postgresql to the inputs. Otherwise the binaries
           ;; and wrapped files will refer to them, even if the user choices none
           ;; of these.  Executables are searched on $PATH then.
           qtbase-5
           sqlite))
    (arguments
     `(#:tests? #f ;; TODO 135/167 tests fail
       #:configure-flags '("-DDATABASE_BACKEND=SQLITE") ; lightweight
       #:modules ((ice-9 textual-ports)
                  ,@%qt-build-system-modules)
       #:phases
       (modify-phases (@ (guix build qt-build-system) %standard-phases)
         (add-before 'configure 'add-definitions
           (lambda* (#:key outputs inputs #:allow-other-keys)
             (let ((out   (assoc-ref outputs "out")))
               (with-output-to-file "CMakeLists.txt.new"
                 (lambda _
                   (display
                    (string-append
                     "add_compile_definitions(\n"
                     "NIX_OUT=\"" out "\"\n"
                     ;; pin binaries for mysql backend
                     ")\n\n"))
                   (display
                    (call-with-input-file "CMakeLists.txt"
                      get-string-all))))
               (rename-file "CMakeLists.txt.new" "CMakeLists.txt"))
             #t)))))
    (home-page "https://kontact.kde.org/components/akonadi.html")
    (synopsis "Extensible cross-desktop storage service for PIM")
    (description "Akonadi is an extensible cross-desktop Personal Information
Management (PIM) storage service.  It provides a common framework for
applications to store and access mail, calendars, addressbooks, and other PIM
data.

This package contains the Akonadi PIM storage server and associated
programs.")
    (license license:fdl1.2+)))

(define-public akonadi-calendar
  (package
    (name "akonadi-calendar")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-calendar-" version ".tar.xz"))
       (sha256
        (base32 "001ndvgqn6x70s7gdya1f1vr080mfkypam3k6z0i2ivlpymc3wly"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           boost
           grantlee
           grantleetheme
           kcalendarcore
           kcalutils
           kcodecs
           kcontacts
           ki18n
           kiconthemes
           kidentitymanagement
           kio
           kitemmodels
           kmailtransport
           kmime
           kpimtextedit
           ksmtp
           ktextwidgets
           kwallet
           qtbase-5))
    (arguments
     `(#:tests? #f))  ;; TODO: 1/1 test fails
    (home-page "https://api.kde.org/kdepim/akonadi/html/index.html")
    (synopsis "Library providing calendar helpers for Akonadi items")
    (description "This library manages calendar specific actions for
collection and item views.")
    (license license:lgpl2.0+)))

(define-public akonadi-contacts
  (package
    (name "akonadi-contacts")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-contacts-" version ".tar.xz"))
       (sha256
        (base32 "1aq81569kz529n66dl5jjzamy6kxw0xk5bcmjfvb3wpxznhiigqm"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           boost
           grantlee
           grantleetheme
           kauth
           kcmutils
           kcodecs
           kcompletion
           kconfigwidgets
           kcontacts
           kcoreaddons
           kdbusaddons
           ki18n
           kiconthemes
           kitemmodels
           kitemviews
           kjobwidgets
           kmime
           kservice
           ktextwidgets
           kwidgetsaddons
           kxmlgui
           libkleo
           prison
           kio
           qtbase-5
           solid
           sonnet))
    (home-page "https://api.kde.org/kdepim/akonadi/html/index.html")
    (synopsis "Akonadi contacts access library")
    (description "Akonadi Contacts is a library that effectively bridges the
type-agnostic API of the Akonadi client libraries and the domain-specific
KContacts library.  It provides jobs, models and other helpers to make working
with contacts and addressbooks through Akonadi easier.

The library provides a complex dialog for editing contacts and several models
to list and filter contacts.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public akonadi-mime
  (package
    (name "akonadi-mime")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-mime-" version ".tar.xz"))
       (sha256
        (base32 "1nd6bf26lb5wfhzh4kn37iwmb6savcq9wsaph5c7jg6m0bdix1fn"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules libxslt ;; xslt for generating interface descriptions
           shared-mime-info))
    (inputs
     (list akonadi
           boost
           kcodecs
           kconfig
           kconfigwidgets
           kdbusaddons
           ki18n
           kio
           kitemmodels
           kmime
           kwidgetsaddons
           kxmlgui
           qtbase-5))
    (home-page "https://api.kde.org/kdepim/akonadi/html/index.html")
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'copy-desktop-file-early
           (lambda _
             (let ((plugins-dir "/tmp/.local/share/akonadi/plugins/serializer"))
               (mkdir-p plugins-dir)
               (copy-file "serializers/akonadi_serializer_mail.desktop"
                          (string-append plugins-dir "/akonadi_serializer_mail.desktop")))
             #t))
         (add-before 'check 'check-setup
           (lambda _
             (setenv "HOME" "/tmp")
             #t)))))
    (synopsis "Akonadi MIME handling library")
    (description "Akonadi Mime is a library that effectively bridges the
type-agnostic API of the Akonadi client libraries and the domain-specific
KMime library.  It provides jobs, models and other helpers to make working
with emails through Akonadi easier.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public akonadi-notes
  (package
    (name "akonadi-notes")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-notes-" version ".tar.xz"))
       (sha256
        (base32 "1s3bxnqsjnlgsnia0nvqyc3m1ppzanzna9598lgwbmz053rgn7ck"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi kcodecs ki18n kmime qtbase-5))
    (home-page "https://api.kde.org/kdepim/akonadi/html/index.html")
    (synopsis "Akonadi notes access library")
    (description "Akonadi Notes is a library that effectively bridges the
type-agnostic API of the Akonadi client libraries and the domain-specific
KMime library.  It provides a helper class for note attachments and for
wrapping notes into KMime::Message objects.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public akonadi-search
  (package
    (name "akonadi-search")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-search-" version ".tar.xz"))
       (sha256
        (base32 "1hp2x8y59azl59znrqhrjn4n1bs2iqnkdsldv1f2k1ima6z5f4qy"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules
           ;; For tests.
           dbus))
    (inputs
     (list akonadi
           akonadi-mime
           boost
           kcalendarcore
           kcmutils
           kcontacts
           kcrash
           kdbusaddons
           ki18n
           kio
           kitemmodels
           kmime
           krunner
           kwindowsystem
           qtbase-5
           xapian))
    (arguments
     `(#:phases (modify-phases %standard-phases
                  (add-after 'unpack 'disable-failing-test
                    (lambda _
                      ;; FIXME: This test fails because it fails to establish
                      ;; a socket connection, seemingly due to failure during
                      ;; DBus communication.  See also 'korganizer'.
                      (substitute* "agent/autotests/CMakeLists.txt"
                        ((".*schedulertest\\.cpp.*")
                         ""))
                      #t))
                  (replace 'check
                    (lambda* (#:key tests? #:allow-other-keys)
                      (when tests?
                        (invoke "dbus-launch" "ctest" "-E"
                                "akonadi-sqlite-collectionindexingjobtest")))))))
    (home-page "https://api.kde.org/kdepim/akonadi/html/index.html")
    (synopsis "Akonadi search library")
    (description "This package provides a library used to search in the
Akonadi PIM data server.  It uses Xapian for indexing and querying.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kincidenceeditor
  (package
    (name "kincidenceeditor")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/incidenceeditor-" version ".tar.xz"))
       (sha256
        (base32 "1xpp5lw60mvpjsjsxmicfa5y2d68wnb9vm4yb1krwkihm852ziny"))))
    (properties `((upstream-name . "incidenceeditor")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-contacts
           akonadi-mime
           boost
           kcalendarcore
           kcalendarsupport
           kcalutils
           kcodecs
           kcontacts
           kdbusaddons
           kdepim-apps-libs
           kdiagram
           keventviews
           ki18n
           kiconthemes
           kidentitymanagement
           kio
           kitemmodels
           kldap
           kmailtransport
           kmime
           kpimtextedit
           ktextwidgets
           kwallet
           libkdepim
           qtbase-5))
    (home-page "https://invent.kde.org/pim/incidenceeditor")
    (synopsis "KDE PIM library for editing incidences")
    (description "This library provides an incidence editor for KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kaddressbook
  (package
    (name "kaddressbook")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kaddressbook-" version ".tar.xz"))
       (sha256
        (base32 "04ac5z9603lxylc6x55chnc0w59mx3z92nyvfnvjvp1ga77si36b"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-search
           boost
           gpgme
           grantlee
           grantleetheme
           kcalendarcore
           kcmutils
           kcompletion
           kcontacts
           kcrash
           kdbusaddons
           kdoctools
           ki18n
           kiconthemes
           kimap
           kio
           kitemmodels
           kmime
           kontactinterface
           kparts
           kpimcommon
           kpimtextedit
           ktextwidgets
           kxmlgui
           libkdepim
           libkleo
           oxygen-icons ; default icon set, required for tests
           prison
           qgpgme
           qtbase-5))
    (home-page "https://kontact.kde.org/components/kaddressbook.html")
    (synopsis "Address Book application to manage your contacts")
    (description "KAddressBook stores all the personal details of your family,
friends and other contacts.  It supports large variety of services, including
NextCloud, Kolab, Google Contacts, Microsoft Exchange (EWS) or any standard
CalDAV server.")
    (license (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kalarmcal
  (package
    (name "kalarmcal")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kalarmcal-" version ".tar.xz"))
       (sha256
        (base32 "15l893iv4smlppk7k682m9hwrph84p5chx5mgxixjxl28c1blcc8"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           boost
           kcalendarcore
           kcalutils
           kcompletion
           kconfig
           kconfigwidgets
           kcoreaddons
           kdbusaddons
           kholidays
           ki18n
           kidentitymanagement
           kio
           kitemmodels
           kpimtextedit
           ktextwidgets
           kxmlgui
           qtbase-5))
    (arguments
     `(#:tests? #f)) ;; TODO: TZ setup
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library for handling kalarm calendar data")
    (description "This library provides access to and handling of kalarm
calendar data.")
    (license  license:lgpl2.0+)))

(define-public kblog
  (package
    (name "kblog")
    (version "20.04.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kblog-" version ".tar.xz"))
       (sha256
        (base32 "1d5r9ivc1xmhkrz780xga87p84h7dnxjl981qap16gy37sxahcjr"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcalendarcore
           kcoreaddons
           ki18n
           kio
           kxmlrpcclient
           qtbase-5
           syndication))
    ;; Note: Some tests take up to 90 sec.
    (home-page "https://invent.kde.org/pim/kblog")
    (synopsis "Client-side support library for web application remote blogging
APIs")
    (description "KBlog is a library for calling functions on Blogger 1.0,
MetaWeblog, MovableType and GData compatible blogs.  It calls the APIs using
KXmlRpcClient and Syndication.  It supports asynchronous sending and fetching
of posts and, if supported on the server, multimedia files.  Almost every
modern blogging web application that provides an XML data interface supports
one of the APIs mentioned above.")
    (license license:lgpl2.0+)))

(define-public kcalendarsupport
  (package
    (name "kcalendarsupport")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/calendarsupport-" version ".tar.xz"))
       (sha256
        (base32 "021rr06ln7l0v2xjzsij4r71jwpy1w1r761bjad0ywprwkdc93bm"))))
    (properties `((upstream-name . "calendarsupport")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-mime
           akonadi-notes
           boost
           kcalendarcore
           kcalutils
           kcompletion
           kdbusaddons
           kguiaddons
           kholidays
           ki18n
           kiconthemes
           kidentitymanagement
           kio
           kitemmodels
           kmime
           kpimcommon
           kpimtextedit
           ktextwidgets
           kxmlgui
           qtbase-5))
    (home-page "https://api.kde.org/stable/calendarsupport/")
    (synopsis "Calendar Support library for KDE PIM")
    (description "The Calendar Support library provides helper utilities for
calendaring applications.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kcalutils
  (package
    (name "kcalutils")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kcalutils-" version ".tar.xz"))
       (sha256
        (base32 "0i474by8pyv64b7i807kym2q4wkhnyyn21vn56dbgp1awpi198i8"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules libxml2)) ;; xmllint required for tests
    (inputs
     (list grantlee
           kcalendarcore
           kcodecs
           kconfig
           kconfigwidgets
           kcoreaddons
           ki18n
           kiconthemes
           kidentitymanagement
           kpimtextedit
           ktextwidgets
           kwidgetsaddons
           oxygen-icons ; default icon set, required for tests
           qtbase-5))
    (arguments
     `(#:tests? #f)) ;; TODO: seem to pull in some wrong theme
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library with utility functions for the handling of calendar
data")
    (description "This library provides a utility and user interface
functions for accessing calendar data using the kcalcore API.")
    (license  license:lgpl2.0+)))

(define-public kdepim-apps-libs
  (package
    (name "kdepim-apps-libs")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kdepim-apps-libs-" version ".tar.xz"))
       (sha256
        (base32 "0m9qrfjs97anh9h6ibggx23ddlm1zkxjap2iyf3gf672ip01fvci"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-contacts
           boost
           gpgme
           grantlee
           grantleetheme
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           ki18n
           kimap
           kio
           kitemmodels
           kmime
           kpimcommon
           kservice
           kwidgetsaddons
           libkleo
           prison
           qgpgme
           qtbase-5))
    (home-page "https://invent.kde.org/pim/kdepim-apps-libs")
    (synopsis "KDE PIM mail related libraries and data files")
    (description "This package provides mail related libraries and data files
for KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kdepim-runtime
  (package
    (name "kdepim-runtime")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kdepim-runtime-" version ".tar.xz"))
       (sha256
        (base32 "1in4x4wvgclkni72cfkw9jx35d0qd0jmfwybm3ksx5qx5sbki9gg"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules dbus kdoctools libxslt shared-mime-info))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-contacts
           akonadi-mime
           akonadi-notes
           boost
           cyrus-sasl
           kalarmcal
           kcalendarcore
           kcalutils
           kcodecs
           kconfig
           kconfigwidgets
           kcontacts
           kdav
           kholidays
           kidentitymanagement
           kimap
           kio
           kitemmodels
           kmailtransport
           kmbox
           kmime
           knotifications
           knotifyconfig
           kpimcommon
           kpimtextedit
           kross
           ktextwidgets
           kwallet
           kwindowsystem
           libkgapi
           ;; TODO: libkolab
           qca
           qtbase-5
           qtdeclarative
           qtnetworkauth
           qtspeech
           qtwebchannel
           qtwebengine
           qtxmlpatterns))
    (arguments
      ;; TODO: 5/45 tests fail for quite different reasons, even with
      ;; "offscreen" and dbus
     `(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (add-after 'set-paths 'extend-CPLUS_INCLUDE_PATH
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; FIXME: <Akonadi/KMime/SpecialMailCollections> is not
                      ;; found during one of the compilation steps without
                      ;; this hack.
                      (setenv "CPLUS_INCLUDE_PATH"
                              (string-append
                               (search-input-directory inputs "include/KF5")
                               ":" (or (getenv "CPLUS_INCLUDE_PATH") ""))))))))
    (home-page "https://invent.kde.org/pim/kdepim-runtime")
    (synopsis "Runtime components for Akonadi KDE")
    (description "This package contains Akonadi agents written using KDE
Development Platform libraries.  Any package that uses Akonadi should probably
pull this in as a dependency.  The kres-bridges is also parts of this
package.")
    (license ;; Files vary a lot regarding the license. GPL2+ and LGPL2.1+
     ;; have been used in those I checked. But the archive also includes
     ;; license texts for GPL3 and AGPL3.
     (list license:gpl2+ license:lgpl2.0+))))

(define-public keventviews
  (package
    (name "keventviews")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/eventviews-" version ".tar.xz"))
       (sha256
        (base32 "0si9p95rgp7mgkzhzwyy10zrwzy1kipbhm1y96yjlc9rxi3jrc73"))))
    (properties `((upstream-name . "eventviews")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-contacts
           boost
           kcalendarcore
           kcalendarsupport
           kcalutils
           kcodecs
           kcompletion
           kconfigwidgets
           kcontacts
           kdbusaddons
           kdiagram
           kguiaddons
           kholidays
           ki18n
           kiconthemes
           kidentitymanagement
           kio
           kitemmodels
           kmime
           kpimtextedit
           kservice
           ktextwidgets
           kxmlgui
           libkdepim
           qtbase-5))
    (home-page "https://invent.kde.org/pim/eventviews")
    (synopsis "KDE PIM library for creating events")
    (description "This library provides an event creator for KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kgpg
  (package
    (name "kgpg")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kgpg-" version ".tar.xz"))
       (sha256
        (base32 "03d3gsbara7ga2cyrhafkw11qq9cj804h9vpvxl4wd2a9c90snkh"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules gnupg ;; TODO: Remove after gpgme uses fixed path
           kdoctools))
    (inputs
     (list akonadi
           akonadi-contacts
           boost
           gpgme
           karchive
           kcodecs
           kcontacts
           kcoreaddons
           kcrash
           kdbusaddons
           ki18n
           kiconthemes
           kio
           kitemmodels
           kjobwidgets
           knotifications
           kservice
           ktextwidgets
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           oxygen-icons ;; default icon set
           qtbase-5))
    (home-page "https://kde.org/applications/utilities/org.kde.kgpg")
    (synopsis "Graphical front end for GNU Privacy Guard")
    (description "Kgpg manages cryptographic keys for the GNU Privacy Guard,
and can encrypt, decrypt, sign, and verify files.  It features a simple editor
for applying cryptography to short pieces of text, and can also quickly apply
cryptography to the contents of the clipboard.")
    (license license:gpl2+)))

(define-public kidentitymanagement
  (package
    (name "kidentitymanagement")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kidentitymanagement-" version ".tar.xz"))
       (sha256
        (base32 "0flp9p9hlr1zfgvsy5i1nq55p7bvnhqxkxbif1lyw0cq6iblxhgr"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcodecs
           kcompletion
           kconfig
           kcoreaddons
           kemoticons
           kiconthemes
           kio
           kpimtextedit
           ktextwidgets
           kxmlgui
           qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'check 'set-home
           (lambda _
             (setenv "HOME" "/tmp/dummy-home") ;; FIXME: what is this?
             #t)))))
    (home-page "https://kontact.kde.org/")
    (synopsis "Library for shared identities between mail applications")
    (description "This library provides an API for managing user identities.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kimap
  (package
    (name "kimap")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kimap-" version ".tar.xz"))
       (sha256
        (base32 "1x22wfzqp92mn1fy2xl89k9yjfk2vgcva0fd30i9rrqj4aw2rsma"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list cyrus-sasl
           kcoreaddons
           ki18n
           kio
           kmime
           qtbase-5))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library for handling IMAP")
    (description "This library provides a job-based API for interacting with
an IMAP4rev1 server.  It manages connections, encryption and parameter quoting
and encoding, but otherwise provides quite a low-level interface to the
protocol.  This library does not implement an IMAP client; it merely makes it
easier to do so.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kldap
  (package
    (name "kldap")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kldap-" version ".tar.xz"))
       (sha256
        (base32 "0whlp586ycsx0qf0nr81avwscpq62w5js46z7vayy0dxkhrhfayr"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
    (inputs
     (list ki18n kio kwidgetsaddons qtbase-5))
    (propagated-inputs
     (list cyrus-sasl openldap))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library for accessing LDAP")
    (description " This is a library for accessing LDAP with a convenient Qt
style C++ API.  LDAP (Lightweight Directory Access Protocol) is an application
protocol for querying and modifying directory services running over TCP/IP.")
    (license license:lgpl2.0+)))

(define-public kleopatra
  (package
    (name "kleopatra")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kleopatra-" version ".tar.xz"))
       (sha256
        (base32 "1b2nq823gq1v20dnh3hm298fva7cmbn9hh0kmbq22kh98kv8chhh"))))
    (build-system qt-build-system)
    (native-inputs
     (list dbus extra-cmake-modules gnupg ;; TODO: Remove after gpgme uses fixed path
           kdoctools))
    (inputs
     (list boost
           gpgme
           kcmutils
           kcodecs
           kconfig
           kconfigwidgets
           kcoreaddons
           kcrash
           kdbusaddons
           ki18n
           kiconthemes
           kitemmodels
           kmime
           knotifications
           ktextwidgets
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libassuan
           libkleo
           oxygen-icons ;; default icon set
           qgpgme
           qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest"))
             #t)))))
    (home-page "https://kde.org/applications/utilities/org.kde.kleopatra")
    (synopsis "Certificate Manager and Unified Crypto GUI")
    (description "Kleopatra is a certificate manager and a universal crypto
GUI.  It supports managing X.509 and OpenPGP certificates in the GpgSM keybox
and retrieving certificates from LDAP servers.")
    (license ;; GPL for programs, FDL for documentation
     (list license:gpl2+ license:fdl1.2+))))

(define-public kmail
  (package
    (name "kmail")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmail-" version ".tar.xz"))
       (sha256
        (base32 "06qfxzi5pasm6p5ck44sjca96dz8xzd1nndq5lqcyvcxmmnvvz3p"))
       (patches (search-patches "kmail-Fix-missing-link-libraries.patch"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules dbus kdoctools))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-search
           boost
           gpgme
           kbookmarks
           kcalendarcore
           kcalutils
           kcmutils
           kcodecs
           kconfig
           kconfigwidgets
           kcontacts
           kcrash
           kdbusaddons
           kdepim-apps-libs
           kguiaddons
           ki18n
           kiconthemes
           kidentitymanagement
           kimap
           kio
           kitemmodels
           kitemviews
           kjobwidgets
           kldap
           kmailcommon
           kmailtransport
           kmessagelib
           kmime
           kmime
           knotifications
           knotifyconfig
           kontactinterface
           kparts
           kpimcommon
           kpimtextedit
           kservice
           ksyntaxhighlighting
           ktextwidgets
           ktnef
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libgravatar
           libkdepim
           libkleo
           libksieve
           oxygen-icons ; default icon set, required for tests
           qgpgme
           qtbase-5
           qtdeclarative
           qtwebchannel
           qtwebengine
           sonnet))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest" "."))
             #t)))))
    (home-page "https://kontact.kde.org/components/kmail.html")
    (synopsis "Full featured graphical email client")
    (description "KMail supports multiple accounts, mail filtering and email
encryption.  The program let you configure your workflow and it has good
integration into KDE (Plasma Desktop) but is also usable with other Desktop
Environments.

KMail is the email component of Kontact, the integrated personal information
manager from KDE.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kmailcommon
  (package
    (name "kmailcommon")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/mailcommon-" version ".tar.xz"))
       (sha256
        (base32 "0q1k57zx1l7bnzrk1hadjxjn6r4yzz833mgsvaai9sd8qg022x2l"))))
    (properties `((upstream-name . "mailcommon")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules dbus gnupg qttools))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           boost
           gpgme
           karchive
           kcodecs
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kdbusaddons
           kdesignerplugin
           ki18n
           kiconthemes
           kidentitymanagement
           kimap
           kio
           kitemmodels
           kitemviews
           kldap
           kmailimporter
           kmailtransport
           kmessagelib
           kmime
           kpimcommon
           kpimtextedit
           ksyntaxhighlighting
           ktextwidgets
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libkdepim
           libkleo
           libxslt
           phonon
           qgpgme
           qtbase-5))
    (arguments
     `(#:tests? #f))  ;; TODO: 4/56 tests fail, even with "offscreen" and dbus
    (home-page "https://invent.kde.org/pim/mailcommon")
    (synopsis "KDE email utility library")
    (description "The mail common library provides utility functions for
dealing with email.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kmailimporter
  (package
    (name "kmailimporter")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/mailimporter-" version ".tar.xz"))
       (sha256
        (base32 "1929pw0shdzi0yvjnqhak680hjjibg8f8hqy3svyxxhiqbhfjm26"))))
    (properties `((upstream-name . "mailimporter")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-mime
           boost
           karchive
           kcompletion
           kconfig
           kconfigwidgets
           kcoreaddons
           kdbusaddons
           ki18n
           kio
           kitemmodels
           kmime
           kxmlgui
           libkdepim
           qtbase-5))
    (home-page "https://invent.kde.org/pim/mailimporter")
    (synopsis "KDE mail importer library")
    (description "This package provides libraries for importing mails other
e-mail client programs into KMail and KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kmailtransport
  (package
    (name "kmailtransport")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmailtransport-" version ".tar.xz"))
       (sha256
        (base32 "1swqlgzxzlqffm119sbhszy9lr93m8lzwygr0q4raa660b6yiavm"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
    (inputs
     (list akonadi
           akonadi-mime
           boost
           cyrus-sasl
           kcalendarcore
           kcmutils
           kcontacts
           kdbusaddons
           kconfigwidgets
           ki18n
           kitemmodels
           kio
           kmime
           ksmtp
           ktextwidgets
           kwallet
           libkgapi
           qtbase-5))
    (arguments
     `(#:tests? #f)) ;; TODO - 3/3 tests fail, require drkonqi
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Mail transport service library")
    (description "This library provides an API and support code for managing
mail transport.")
    (license license:lgpl2.0+)))

(define-public kmbox
  (package
    (name "kmbox")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmbox-" version ".tar.xz"))
       (sha256
        (base32 "03cny38v4y1lmcrs6d34hbj9assqgf51rqryf5rdzkiaq79c1krc"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcodecs kmime qtbase-5))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library for handling mbox mailboxes")
    (description "This is a library for handling mailboxes in mbox format,
using a Qt/KMime C++ API.")
    (license license:lgpl2.0+ )))

(define-public kmessagelib
  (package
    (name "kmessagelib")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/messagelib-" version ".tar.xz"))
       (sha256
        (base32 "0ln473gdwsscjpsh50h2cbazxbc8qy1mmll9lsfngfw1qq49dwsp"))))
    (properties `((upstream-name . "messagelib")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules gnupg libxml2))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-notes
           akonadi-search
           boost
           gpgme
           grantlee
           grantleetheme
           karchive
           kcalendarcore
           kcodecs
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kdbusaddons
           kguiaddons
           ki18n
           kiconthemes
           kidentitymanagement
           kimap
           kio
           kitemmodels
           kitemviews
           kjobwidgets
           kldap
           kmailtransport
           kmbox
           kmime
           knewstuff
           kpimcommon
           kpimtextedit
           kservice
           ksyntaxhighlighting
           ktextwidgets
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libgravatar
           libkdepim
           libkleo
           qca
           qgpgme
           qtbase-5
           qtdeclarative
           qtwebchannel
           qtwebengine
           qtwebkit
           sonnet))
    (arguments
     `(#:tests? #f     ;TODO many test fail for quite different reasons
       #:phases (modify-phases %standard-phases
                  (add-after 'set-paths 'extend-CPLUS_INCLUDE_PATH
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; FIXME: One of the compilation steps fail to find
                      ;; <QPrinter> without this hack.
                      (setenv "CPLUS_INCLUDE_PATH"
                              (string-append (assoc-ref inputs "qtbase")
                                             "/include/qt5/QtPrintSupport:"
                                             (or (getenv "CPLUS_INCLUDE_PATH") ""))))))))
    (home-page "https://invent.kde.org/pim/messagelib")
    (synopsis "KDE PIM messaging libraries")
    (description "This package provides several libraries for messages,
e.g. a message list, a mime tree parse, a template parser and the
kwebengineviewer.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kmime
  (package
    (name "kmime")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmime-" version ".tar.xz"))
       (sha256
        (base32 "1dkdxfr1ry10qyql5sp1ai4li11f0ncf9hipg27j59y70mlyrl2r"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcodecs ki18n qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-test-case
           (lambda _
             ;; This is curious: autotests/CMakeLists.txt sets LC_TIME=C, but
             ;; the Qt locale returns different. See kmime commit 3a9651d26a.
             (substitute* "autotests/dateformattertest.cpp"
               (("(Today|Yesterday) 12:34:56" line day)
                (string-append day " 12:34 PM")))
             #t)))))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library for handling MIME data")
    (description "This library provides an API for handling MIME
data.  MIME (Multipurpose Internet Mail Extensions) is an Internet Standard
that extends the format of e-mail to support text in character sets other than
US-ASCII, non-text attachments, multi-part message bodies, and header
information in non-ASCII character sets.")
    (license license:lgpl2.0+)))

(define-public knotes
  (package
    (name "knotes")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/knotes-" version ".tar.xz"))
       (sha256
        (base32 "13h4n7fb5p6g1f5kmw6pblpd76j904psm30s3a5d3kykni57dijx"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules libxslt))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-notes
           akonadi-search
           boost
           grantlee
           grantleetheme
           kcalendarcore
           kcalutils
           kcmutils
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           kcrash
           kdnssd
           kdoctools
           kglobalaccel
           kiconthemes
           kimap
           kitemmodels
           kitemviews
           kmime
           kmime
           knewstuff
           knotifications
           knotifyconfig
           kontactinterface
           kparts
           kpimcommon
           kpimtextedit
           ktextwidgets
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           kxmlgui
           libkdepim
           oxygen-icons ; default icon set, required for tests
           qtbase-5
           qtx11extras))
    (home-page "https://kontact.kde.org/components/knotes.html")
    (synopsis "Note-taking utility")
    (description "KNotes lets you write the computer equivalent of sticky
notes.  The notes are saved automatically when you exit the program, and they
display when you open the program.

Features:
@itemize
@item Write notes in your choice of font and background color
@item Use drag and drop to email your notes
@item Can be dragged into Calendar to book a time-slot
@item Notes can be printed
@end itemize")
    (license (list license:gpl2+ license:lgpl2.0+))))

(define-public kontactinterface
  (package
    (name "kontactinterface")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kontactinterface-" version ".tar.xz"))
       (sha256
        (base32 "0s1qm1wjkvbb1film94r7g88d8vgh26bm0hm6gpyqv5bazw5qx3j"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcoreaddons
           ki18n
           kiconthemes
           kparts
           kwindowsystem
           kxmlgui
           qtbase-5))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Kontact interface library")
    (description " This library provides the glue necessary for
application \"Parts\" to be embedded as a Kontact component (or plugin).")
    (license license:lgpl2.0+)))

(define-public korganizer
  (package
    (name "korganizer")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/korganizer-" version ".tar.xz"))
       (sha256
        (base32 "04lz3ldrr0lpy9zpsg9ja1i9gxzlcjpqcwn3g7l4jjdky4frcr2r"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules dbus qttools kdoctools))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-contacts
           akonadi-mime
           akonadi-notes
           akonadi-search
           boost
           kcalendarcore
           kcalendarsupport
           kcalutils
           kcmutils
           kcodecs
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           kcrash
           kdbusaddons
           kdepim-apps-libs
           keventviews
           kholidays
           kiconthemes
           kidentitymanagement
           kimap
           kincidenceeditor
           kitemmodels
           kitemviews
           kjobwidgets
           kldap
           kmailtransport
           kmime
           knewstuff
           knotifications
           kontactinterface
           kparts
           kpimcommon
           kpimtextedit
           kservice
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libkdepim
           oxygen-icons ; default icon set, required for tests
           phonon
           qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'disable-failing-test
           (lambda _
             ;; FIXME: This test started failing after the 20.04 update
             ;; seemingly due to DBus communication issues.
             ;; See also 'akonadi-search' for a similar test failure.
             (substitute* "src/autotests/CMakeLists.txt"
               ((".*test_advanced\\(koeventpopupmenutest\\.cpp.*")
                ""))
             #t))
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest" "."))
             #t)))))
    (home-page "https://kontact.kde.org/components/korganizer.html")
    (synopsis "Organizational assistant, providing calendars and other similar
functionality to help you organize your life.")
    (description "KOrganizer is the calendar and scheduling component of
Kontact.  It provides management of events and tasks, alarm notification, web
export, network transparent handling of data, group scheduling, import and
export of calendar files and more.  It is able to work together with a wide
variety of calendaring services, including NextCloud, Kolab, Google Calendar
and others.  KOrganizer is fully customizable to your needs and is an integral
part of the Kontact suite, which aims to be a complete solution for organizing
your personal data.  KOrganizer supports the two dominant standards for storing
and exchanging calendar data, vCalendar and iCalendar.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kpeoplevcard
  (package
    (name "kpeoplevcard")
    (version "0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://download.kde.org/stable/kpeoplevcard/"
                                  version "/kpeoplevcard-" version ".tar.xz"))
              (sha256
               (base32
                "1hv3fq5k0pps1wdvq9r1zjnr0nxf8qc3vwsnzh9jpvdy79ddzrcd"))))
    (build-system qt-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (replace 'check-setup
                    (lambda _
                      (setenv "HOME" "/tmp")
                      #t)))))
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcontacts kpeople qtbase-5))
    (home-page "https://invent.kde.org/pim/kpeoplevcard")
    (synopsis "Expose vCard contacts to KPeople")
    (description
     "This plugins adds support for vCard (also known as @acronym{VCF,
Virtual Contact File}) files to the KPeople contact management library.")
    (license license:lgpl2.1+)))

(define-public kpimcommon
  (package
    (name "kpimcommon")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/pimcommon-" version ".tar.xz"))
       (sha256
        (base32 "1pnhjhnjx98wdc3dg71qgjjj3dsncl56d86cagkk2spicv901p69"))))
    (properties `((upstream-name . "pimcommon")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list karchive
           akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-search
           boost
           grantlee
           grantleetheme
           ;; TODO: ("kaccounts" ,kaccounts)
           kcalendarcore
           kcmutils
           kcodecs
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           kdesignerplugin
           ki18n
           kiconthemes
           kimap
           kio
           kirigami ;; run-time dependency
           kitemmodels
           kitemviews
           kjobwidgets
           kldap
           kmime
           knewstuff
           kpimtextedit
           ktextwidgets
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libkdepim
           libxslt
           purpose
           qtbase-5
           qtwebengine))
    (arguments
     `(#:tests? #f)) ;; TODO tests hang
    (home-page "https://invent.kde.org/pim/pimcommon")
    (synopsis "Common libraries for KDE PIM")
    (description "This package provides common libraries for KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public libgravatar
  (package
    (name "libgravatar")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libgravatar-" version ".tar.xz"))
       (sha256
        (base32 "0981ci2kr20v4fk11h57rqya0brgslfazpgq1yk5yqiwyqqm49r2"))))
    (build-system qt-build-system)
    (native-inputs
     `(("extra-cmake-modules" ,extra-cmake-modules)))
    (inputs
     `(("kconfig" ,kconfig)
       ("ki18n" ,ki18n)
       ("kio" ,kio)
       ("kpimcommon" ,kpimcommon)
       ("ktextwidgets" ,ktextwidgets)
       ("kwidgetsaddons" ,kwidgetsaddons)
       ("qtbase" ,qtbase-5)))
    (arguments
     `(#:tests? #f)) ;; 2/7 tests fail (due to network issues?)
    (home-page "https://invent.kde.org/pim/libgravatar")
    (synopsis "Online avatar lookup library")
    (description "This library retrieves avatar images based on a
hash from a person's email address, as well as local caching to avoid
unnecessary network operations.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kpimtextedit
  (package
    (name "kpimtextedit")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kpimtextedit-" version ".tar.xz"))
       (sha256
        (base32 "0j6d4sv405c3x0ww75qsww94apidsb8aaqf59akhv96zmv0vx5wy"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list grantlee
           kcodecs
           kconfigwidgets
           kcoreaddons
           kdesignerplugin
           kemoticons
           ki18n
           kiconthemes
           kio
           ksyntaxhighlighting
           ktextwidgets
           kwidgetsaddons
           kxmlgui
           qtbase-5
           qtspeech
           sonnet))
    (arguments
     `(#:tests? #f)) ;; TODO - test suite hangs
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/")
    (synopsis "Library providing a textedit with PIM-specific features")
    (description "This package provides a textedit with PIM-specific features.
It also provides so-called rich text builders which can convert the formatted
text in the text edit to all kinds of markup, like HTML or BBCODE.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public ksmtp
  (package
    (name "ksmtp")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/ksmtp-" version ".tar.xz"))
       (sha256
        (base32 "1xyaahibm0dc3qdwiak5yqa66szxaxnylvqxi6k21ayvzn2vxbhx"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list cyrus-sasl
           kcodecs
           kconfig
           kcoreaddons
           ki18n
           kio
           qtbase-5))
    (arguments
     `(#:tests? #f ;; TODO: does not find sasl mechs
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'Use-KDE_INSTALL_TARGETS_DEFAULT_ARGS-when-installing
           (lambda _
             (substitute* "src/CMakeLists.txt"
               (("^(install\\(.* )\\$\\{KF5_INSTALL_TARGETS_DEFAULT_ARGS\\}\\)"
                 _ prefix)
                (string-append prefix "${KDE_INSTALL_TARGETS_DEFAULT_ARGS})")))
             #t)))))
    (home-page "https://invent.kde.org/pim/ksmtp")
    (synopsis "Library for sending email through an SMTP server")
    (description "This library provides an API for handling SMTP
services.  SMTP (Simple Mail Transfer Protocol) is the most prevalent Internet
standard protocols for e-mail transmission.")
    (license license:lgpl2.0+)))

(define-public ktnef
  (package
    (name "ktnef")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/ktnef-" version ".tar.xz"))
       (sha256
        (base32 "0cn5p32w2kas56yyc15c22kll4hd02lvvxz2n6cz1wda8alspj19"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcalendarcore
           kcalutils
           kcodecs
           kconfig
           kcontacts
           kcoreaddons
           ki18n
           qtbase-5))
    (home-page "https://api.kde.org/stable/kdepimlibs-apidocs/ktnef/html/")
    (synopsis "Library for handling mail attachments using TNEF format")
    (description "Ktnef is a library for handling data in the TNEF
format (Transport Neutral Encapsulation Format, a proprietary format of e-mail
attachment used by Microsoft Outlook and Microsoft Exchange Server).  The API
permits access to the actual attachments, the message properties (TNEF/MAPI),
and allows one to view/extract message formatted text in Rich Text Format.")
    (license license:lgpl2.0+)))

(define-public libkdepim
  (package
    (name "libkdepim")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkdepim-" version ".tar.xz"))
       (sha256
        (base32 "0bask561laxgkgm3rxfpyxqs6jx1l9xjk058lhycq0pik6vwhdha"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           akonadi-search
           boost
           kcmutils
           kcodecs
           kcalendarcore
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           kdbusaddons
           kdesignerplugin
           ki18n
           kiconthemes
           kio
           kitemmodels
           kitemviews
           kjobwidgets
           kldap
           kmime
           kwallet
           kwidgetsaddons
           qtbase-5))
    (home-page "https://invent.kde.org/pim/libkdepim")
    (synopsis "Libraries for common KDE PIM apps")
    (description "This package provided libraries for common KDE PIM apps.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public libkgapi
  (package
    (name "libkgapi")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkgapi-" version ".tar.xz"))
       (sha256
        (base32 "0nvd5fqrvyb7c3g7rf1lxbbv38q9sqnhd6irgx7awwgw92inxky4"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules qttools))
    (inputs
     (list cyrus-sasl
           ki18n
           kcontacts
           kcalendarcore
           kio
           kwallet
           kwindowsystem
           qtbase-5
           qtdeclarative
           qtwebchannel
           qtwebengine))
    (arguments
     `(#:tests? #f)) ;; TODO 6/48 tests fail
    (home-page "https://invent.kde.org/pim/libkgapi")
    (synopsis "Library for accessing various Google services via their public
API")
    (description "@code{LibKGAPI} is a C++ library that implements APIs for
various Google services.")
    (license license:lgpl2.0+)))

(define-public libkleo
  (package
    (name "libkleo")
    (version "20.04.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkleo-" version ".tar.xz"))
       (sha256
        (base32 "0rijpmqyx4mrr7csik3vkfcra7kfywk6yz548fmq3ha8wa9ax8fv"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools qttools))
    (inputs
     (list boost
           gpgme
           kcodecs
           kcompletion
           kconfig
           kcoreaddons
           kcrash
           ki18n
           kitemmodels
           kwidgetsaddons
           kwindowsystem
           kpimtextedit
           qgpgme
           qtbase-5))
    (home-page "https://invent.kde.org/pim/libkleo")
    (synopsis "KDE PIM cryptographic library")
    (description "@code{libkleo} is a library for Kleopatra and other parts of
KDE using certificate-based crypto.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public libksieve
  (package
    (name "libksieve")
    (version "21.12.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libksieve-" version ".tar.xz"))
       (sha256
        (base32 "03aaqqb5g9iv49crrf7zbmsri8jjszn5wfvmcw559swalmmyzb4i"))
       (patches (search-patches "libksieve-Fix-missing-link-libraries.patch"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
    (inputs
     (list akonadi
           cyrus-sasl
           karchive
           ki18n
           kiconthemes
           kidentitymanagement
           kimap
           kio
           kmailtransport
           kmime
           knewstuff
           kpimcommon
           kpimtextedit
           ksyntaxhighlighting
           ktextwidgets
           kwallet
           kwindowsystem
           libkdepim
           qtbase-5
           qtdeclarative
           qtwebchannel
           qtwebengine))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'substitute
           (lambda _
             ;; Disable a failing test
             ;; sieveeditorhelphtmlwidgettest fails with `sigtrap`
             (substitute*
                 "src/ksieveui/editor/webengine/autotests/CMakeLists.txt"
               (("^\\s*(add_test|ecm_mark_as_test)\\W" line)
                (string-append "# " line)))
             #t)))))
    (home-page "https://invent.kde.org/pim/libksieve")
    (synopsis "KDE Sieve library")
    (description "Sieve is a language that can be used filter emails.  KSieve
is a Sieve parser and interpreter library for KDE.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

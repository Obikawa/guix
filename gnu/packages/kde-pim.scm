;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2017, 2019, 2020 Hartmut Goebel <h.goebel@crazy-compilers.com>
;;; Copyright © 2020 Marius Bakke <marius@gnu.org>
;;; Copyright © 2021, 2022 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2022 Brendan Tildesley <mail@brendan.scot>
;;; Copyright © 2022 Petr Hodina <phodina@protonmail.com>
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-" version ".tar.xz"))
       (sha256
        (base32 "026srxk7da20vfhbj7jh8aip3sylpm61czwblj3wxxps0vbxxs2g"))
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
               (rename-file "CMakeLists.txt.new" "CMakeLists.txt")))))))
    (home-page "https://kontact.kde.org/components/akonadi")
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-calendar-" version ".tar.xz"))
       (sha256
        (base32 "0hzy6y9pxa06k0pp5yr84i0sv15qgzjn7nrlmsylm6iy7fspqqbq"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-contacts-" version ".tar.xz"))
       (sha256
        (base32 "04ixj09s27q8pbmfrb1475bc0h84sb5ikfxzpc4i5b3whx40g9dm"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-mime-" version ".tar.xz"))
       (sha256
        (base32 "1bcrbf5z9175p206cvm5s6zq882nb32cf9akdcbnadqiibrpxkxv"))))
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
                          (string-append plugins-dir "/akonadi_serializer_mail.desktop")))))
         (add-before 'check 'check-setup
           (lambda _
             (setenv "HOME" "/tmp"))))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-notes-" version ".tar.xz"))
       (sha256
        (base32 "0xkcw9izgxfzglciig2i4wiz6iflzjg0d6dp1nq6p1kwxwc899sb"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/akonadi-search-" version ".tar.xz"))
       (sha256
        (base32 "1id6zzjxc9zvpz1ryj2zn1yff5ak04r1mlk9cklbj99frzf0wv6p"))))
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
                         ""))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/incidenceeditor-" version ".tar.xz"))
       (sha256
        (base32 "1sbflfggpqhwhg3iw46462z3p83sjhlx6f1fvgz251m020vqq9xa"))))
    (properties `((upstream-name . "incidenceeditor")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules dbus))
    (inputs
     (list akonadi
           akonadi-calendar
           akonadi-contacts
           akonadi-mime
           boost
           grantlee
           grantleetheme
           kcalendarcore
           kcalendarsupport
           kcalutils
           kcodecs
           kcontacts
           kdbusaddons
           kdiagram
           keventviews
           ki18n
           kiconthemes
           kidentitymanagement
           kimap
           kio
           kitemmodels
           kldap
           kmailtransport
           kmime
           kpimcommon
           kpimtextedit
           ktextwidgets
           kwallet
           libkdepim
           qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest" ;; FIXME: test fails.
                       "-E" "akonadi-sqlite-incidencedatetimetest")))))))
    (home-page "https://invent.kde.org/pim/incidenceeditor")
    (synopsis "KDE PIM library for editing incidences")
    (description "This library provides an incidence editor for KDE PIM.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kaddressbook
  (package
    (name "kaddressbook")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kaddressbook-" version ".tar.xz"))
       (sha256
        (base32 "1hzq0fdy99l1kqw14d582l0s56gvrw86abihib6k4az4c6g3c0md"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
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
           breeze-icons ; default icon set, required for tests
           prison
           qgpgme
           qtbase-5))
    (home-page "https://kontact.kde.org/components/kaddressbook")
    (synopsis "Address Book application to manage your contacts")
    (description "KAddressBook stores all the personal details of your family,
friends and other contacts.  It supports large variety of services, including
NextCloud, Kolab, Google Contacts, Microsoft Exchange (EWS) or any standard
CalDAV server.")
    (license (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kalarmcal
  (package
    (name "kalarmcal")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kalarmcal-" version ".tar.xz"))
       (sha256
        (base32 "160pmr702b68hys9l02azvrv6pagy1r2whw0zp3jlf6863p9fkqr"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/calendarsupport-" version ".tar.xz"))
       (sha256
        (base32 "0annni037cp1ga2lj2gkjxlkygnaxna4fs095lbaqp5zljz3g8vp"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kcalutils-" version ".tar.xz"))
       (sha256
        (base32 "006sfkjzyid8byl2mmyn1is4nra9wjqh21ksd5g1kv948hf1jdcs"))))
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
           breeze-icons ; default icon set, required for tests
           qtbase-5))
    (arguments
     `(#:tests? #f)) ;; TODO: seem to pull in some wrong theme
    (home-page "https://api.kde.org/kdepim/kcalutils/html/index.html")
    (synopsis "Library with utility functions for the handling of calendar
data")
    (description "This library provides a utility and user interface
functions for accessing calendar data using the kcalcore API.")
    (license  license:lgpl2.0+)))

(define-public kdepim-runtime
  (package
    (name "kdepim-runtime")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kdepim-runtime-" version ".tar.xz"))
       (sha256
        (base32 "1ahrnnc9vn0556s4nrsjgc9vbf5rb6yby7fn33p3jjnpgja0mc7m"))))
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
           grantlee
           grantleetheme
           kalarmcal
           kcalendarcore
           kcalutils
           kcmutils
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
           kldap
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
           libkdepim
           libkgapi
           ;; TODO: libkolab
           qca
           qtbase-5
           qtdeclarative
           qtkeychain
           qtnetworkauth
           qtspeech
           qtwebchannel
           qtwebengine
           qtxmlpatterns))
    (arguments
      ;; TODO: 5/45 tests fail for quite different reasons, even with
      ;; "offscreen" and dbus
     `(#:phases (modify-phases %standard-phases
                  (add-after 'set-paths 'extend-CPLUS_INCLUDE_PATH
                    (lambda* (#:key inputs #:allow-other-keys)
                      ;; FIXME: <Akonadi/KMime/SpecialMailCollections> is not
                      ;; found during one of the compilation steps without
                      ;; this hack.
                      (setenv "CPLUS_INCLUDE_PATH"
                              (string-append
                               (assoc-ref inputs "akonadi-mime") "/include/KF5:"
                               (or (getenv "CPLUS_INCLUDE_PATH") "")))))
                  (replace 'check
                    (lambda* (#:key tests? #:allow-other-keys)
                      (when tests?
                        ;; FIXME: Atleast some appear to require network.
                        (invoke "dbus-launch" "ctest" "-E" "\
(akonadi-sqlite-synctest|akonadi-sqlite-pop3test|storecompacttest\
|akonadi-sqlite-ewstest|ewsmoveitemrequest_ut|ewsdeleteitemrequest_ut\
|ewsgetitemrequest_ut|ewsunsubscriberequest_ut|ewssettings_ut\
|templatemethodstest|akonadi-sqlite-serverbusytest|ewsattachment_ut|\\
testmovecollectiontask)")))))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/eventviews-" version ".tar.xz"))
       (sha256
        (base32 "01x9ccwspn1dwkmcxcr8p6pazj6w31pxhx0bzlfr6bgpccicp2w2"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kgpg-" version ".tar.xz"))
       (sha256
        (base32 "1mzq3g4xwg459k0mp9xvg8bhilizadbh4gck1764wq69bxlcyav3"))))
    (build-system qt-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest" "-E" ;; FIXME: Failing test.
                       "(kgpg-import)")))))))
    (native-inputs
     (list extra-cmake-modules gnupg ;; TODO: Remove after gpgme uses fixed path
           dbus ;; Remove after failing test passes
           kdoctools))
    (inputs
     (list akonadi
           akonadi-contacts
           boost
           gpgme
           grantlee
           grantleetheme
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
           breeze-icons ;; default icon set
           qtbase-5))
    (home-page "https://apps.kde.org/utilities/org.kde.kgpg/")
    (synopsis "Graphical front end for GNU Privacy Guard")
    (description "Kgpg manages cryptographic keys for the GNU Privacy Guard,
and can encrypt, decrypt, sign, and verify files.  It features a simple editor
for applying cryptography to short pieces of text, and can also quickly apply
cryptography to the contents of the clipboard.")
    (license license:gpl2+)))

(define-public kidentitymanagement
  (package
    (name "kidentitymanagement")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kidentitymanagement-" version ".tar.xz"))
       (sha256
        (base32 "18xwvlmqhih5jmig2mj3a6mc5awlxdv8f81da6cgm123imhrirk4"))))
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
             (setenv "HOME" "/tmp/dummy-home")))))) ;; FIXME: what is this?
    (home-page "https://kontact.kde.org/")
    (synopsis "Library for shared identities between mail applications")
    (description "This library provides an API for managing user identities.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public kimap
  (package
    (name "kimap")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kimap-" version ".tar.xz"))
       (sha256
        (base32 "11jd9zkvflfh3gqs36fhj8mla3k44xf7zdb0z4nl9sk5nhhgm5px"))))
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
    (home-page "https://api.kde.org/kdepim/kimap/html/index.html")
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kldap-" version ".tar.xz"))
       (sha256
        (base32 "13llsfhx9lfvhf90a3vmpkyh02fjg5sp4fmrwrqyx9hjrbmy1g0a"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools))
    (inputs
     (list ki18n kio kwidgetsaddons qtbase-5 qtkeychain))
    (propagated-inputs
     (list cyrus-sasl openldap))
    (home-page "https://api.kde.org/kdepim/kldap/html/index.html")
    (synopsis "Library for accessing LDAP")
    (description "This is a library for accessing LDAP with a convenient Qt
style C++ API.  LDAP (Lightweight Directory Access Protocol) is an application
protocol for querying and modifying directory services running over TCP/IP.")
    (license license:lgpl2.0+)))

(define-public kleopatra
  (package
    (name "kleopatra")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kleopatra-" version ".tar.xz"))
       (sha256
        (base32 "10f61m0qrs0qipn94jd32gibyj8pcvprs8j7gmac0mym0b3djjls"))))
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
           breeze-icons ;; default icon set
           qgpgme
           qtbase-5))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest")))))))
    (home-page "https://apps.kde.org/utilities/org.kde.kleopatra/")
    (synopsis "Certificate Manager and Unified Crypto GUI")
    (description "Kleopatra is a certificate manager and a universal crypto
GUI.  It supports managing X.509 and OpenPGP certificates in the GpgSM keybox
and retrieving certificates from LDAP servers.")
    (license ;; GPL for programs, FDL for documentation
     (list license:gpl2+ license:fdl1.2+))))

(define-public kmail
  (package
    (name "kmail")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmail-" version ".tar.xz"))
       (sha256
        (base32 "1knh6cf72hidc6jyiw250b708b410fla0c5w83zaavmwv37ah8z0"))))
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
           grantlee
           grantleetheme
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
           knotifications
           knotifyconfig
           kontactinterface
           kparts
           kpimcommon
           kpimtextedit
           kservice
           ksyntaxhighlighting
           ktextwidgets
           kuserfeedback
           ktnef
           kwallet
           kwidgetsaddons
           kwindowsystem
           kxmlgui
           libgravatar
           libkdepim
           libkleo
           libksieve
           breeze-icons ; default icon set, required for tests
           qgpgme
           qtbase-5
           qtdeclarative
           qtkeychain
           qtwebchannel
           qtwebengine
           sonnet))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest" "-E" ;; FIXME: Many failing tests.
                       "(akonadi-sqlite-kmcomposerwintest|\
akonadi-sqlite-tagselectdialogtest|\
akonadi-sqlite-kmcommandstest|\
sendlateragent-sendlaterutiltest|\
sendlateragent-sendlaterconfigtest|\
followupreminder-followupreminderconfigtest|\
akonadi-sqlite-unifiedmailboxmanagertest)")))))))
    (home-page "https://kontact.kde.org/components/kmail/")
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/mailcommon-" version ".tar.xz"))
       (sha256
        (base32 "1zi8zkhv9g4vsylqzjm2wr9v6b20irfxhf4q467cmpqqrqpcp3af"))))
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
           grantlee
           grantleetheme
           karchive
           kcodecs
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kdbusaddons
           kdesignerplugin
           kguiaddons
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
     `(#:tests? #f))  ;; TODO: 12/62 tests fail
    (home-page "https://invent.kde.org/pim/mailcommon")
    (synopsis "KDE email utility library")
    (description "The mail common library provides utility functions for
dealing with email.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public kmailimporter
  (package
    (name "kmailimporter")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/mailimporter-" version ".tar.xz"))
       (sha256
        (base32 "0lcr9zzdf16f82spr9x33jnzr23sx7xk2zvfpzdki3b5jxvapnsk"))))
    (properties `((upstream-name . "mailimporter")))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list akonadi
           akonadi-contacts
           akonadi-mime
           grantlee
           grantleetheme
           boost
           karchive
           kcompletion
           kconfig
           kconfigwidgets
           kcontacts
           kcoreaddons
           kdbusaddons
           ki18n
           kimap
           kio
           kitemmodels
           kmime
           kpimcommon
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmailtransport-" version ".tar.xz"))
       (sha256
        (base32 "0l3pgs781a6is937i0bkz9ykr40l36rwlrirsr4g8wh0gkc3ifi6"))))
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
           qtbase-5
           qtkeychain))
    (arguments
     `(#:tests? #f)) ;; TODO - 3/3 tests fail, require drkonqi
    (home-page "https://api.kde.org/kdepim/kmailtransport/html/index.html")
    (synopsis "Mail transport service library")
    (description "This library provides an API and support code for managing
mail transport.")
    (license license:lgpl2.0+)))

(define-public kmbox
  (package
    (name "kmbox")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmbox-" version ".tar.xz"))
       (sha256
        (base32 "04cl2khj3a7n81nlmxsg8kgszrl22qm6s2kvbrhz39yfzi31cwqr"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules))
    (inputs
     (list kcodecs kmime qtbase-5))
    (home-page "https://api.kde.org/kdepim/kmbox/html/index.html")
    (synopsis "Library for handling mbox mailboxes")
    (description "This is a library for handling mailboxes in mbox format,
using a Qt/KMime C++ API.")
    (license license:lgpl2.0+ )))

(define-public kmessagelib
  (package
    (name "kmessagelib")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/messagelib-" version ".tar.xz"))
       (sha256
        (base32 "0xrhnkahqirsz37lbvx505ll7bfhr25lbq89yqq81bxbzkbvamsw"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kmime-" version ".tar.xz"))
       (sha256
        (base32 "03s7l4lywdvp97h4qjgq06qqcclvnhy83qsrfzv0w2wcl631nnpw"))))
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
                (string-append day " 12:34 PM"))))))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/knotes-" version ".tar.xz"))
       (sha256
        (base32 "07pj0aqwsy1xi5mx7x0h3zmxfg0n4afgjax9a9ihc553xs6k48d7"))))
    (build-system qt-build-system)
    (native-inputs
     (list extra-cmake-modules kdoctools libxslt))
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
           breeze-icons ; default icon set, required for tests
           qtbase-5
           qtx11extras))
    (home-page "https://apps.kde.org/knotes/")
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kontactinterface-" version ".tar.xz"))
       (sha256
        (base32 "1qwx0q4bbk3d720ij37wbd54g9alw6ispjl1mq19hkk3gs5l1c78"))))
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
    (home-page "https://api.kde.org/kdepim/kontactinterface/html/index.html")
    (synopsis "Kontact interface library")
    (description "This library provides the glue necessary for
application \"Parts\" to be embedded as a Kontact component (or plugin).")
    (license license:lgpl2.0+)))

(define-public korganizer
  (package
    (name "korganizer")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/korganizer-" version ".tar.xz"))
       (sha256
        (base32 "072pyzs38dv07mwi4hlfb4rh9jx40dpxac3ywy7kj6nyvbfjmh0r"))))
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
           grantlee
           grantleetheme
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
           breeze-icons ; default icon set, required for tests
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
                ""))))
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests?
               (invoke "dbus-launch" "ctest")))))))
    (home-page "https://apps.kde.org/korganizer/")
    (synopsis "Organizational assistant, providing calendars and other similar
functionality to help you organize your life")
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
              (uri (string-append "mirror://kde/stable/kpeoplevcard/"
                                  version "/kpeoplevcard-" version ".tar.xz"))
              (sha256
               (base32
                "1hv3fq5k0pps1wdvq9r1zjnr0nxf8qc3vwsnzh9jpvdy79ddzrcd"))))
    (build-system qt-build-system)
    (arguments
     '(#:phases (modify-phases %standard-phases
                  (replace 'check-setup
                    (lambda _
                      (setenv "HOME" "/tmp"))))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/pimcommon-" version ".tar.xz"))
       (sha256
        (base32 "1k1d100lr277lgwyzn2ssxsx9x2yd9nfd5657r95vmdnkh2qs517"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libgravatar-" version ".tar.xz"))
       (sha256
        (base32 "1bihy3dfagwc7aday40myqjbn555mkzzaaq7c14ywkmhh99dhvh7"))))
    (build-system qt-build-system)
    (native-inputs (list extra-cmake-modules))
    (inputs (list kconfig
                  ki18n
                  kio
                  kpimcommon
                  ktextwidgets
                  kwidgetsaddons
                  qtbase-5))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/kpimtextedit-" version ".tar.xz"))
       (sha256
        (base32 "19hrqbjcmpi81vmnggrkrv0fcc9inhz5aa5klx0141aylnzfgwsl"))))
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
    (home-page "https://api.kde.org/kdepim/kpimtextedit/html/index.html")
    (synopsis "Library providing a textedit with PIM-specific features")
    (description "This package provides a textedit with PIM-specific features.
It also provides so-called rich text builders which can convert the formatted
text in the text edit to all kinds of markup, like HTML or BBCODE.")
    (license ;; GPL for programs, LGPL for libraries, FDL for documentation
     (list license:gpl2+ license:lgpl2.0+ license:fdl1.2+))))

(define-public ksmtp
  (package
    (name "ksmtp")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/ksmtp-" version ".tar.xz"))
       (sha256
        (base32 "0kdy5gsg1sgccvdk1fpf866xl9m8v8z034jpgf6s7n2pr5r5mni2"))))
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
                (string-append prefix "${KDE_INSTALL_TARGETS_DEFAULT_ARGS})"))))))))
    (home-page "https://invent.kde.org/pim/ksmtp")
    (synopsis "Library for sending email through an SMTP server")
    (description "This library provides an API for handling SMTP
services.  SMTP (Simple Mail Transfer Protocol) is the most prevalent Internet
standard protocols for e-mail transmission.")
    (license license:lgpl2.0+)))

(define-public ktnef
  (package
    (name "ktnef")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/ktnef-" version ".tar.xz"))
       (sha256
        (base32 "1in991n8alkxf40p0wvkr7gdaaz8w4kdw1rsq6sbjil6cs4cr5nl"))))
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
    (home-page "https://api.kde.org/kdepim/ktnef/html/index.html")
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkdepim-" version ".tar.xz"))
       (sha256
        (base32 "0g9jx6z5jf9yqn01xc1k038b4ljr9sil7bwvifc64s38qxl9wmww"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkgapi-" version ".tar.xz"))
       (sha256
        (base32 "1vbk8786mk1irm94bsm97270gnd149nz7w0zqnvwz499f72d21jx"))))
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
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libkleo-" version ".tar.xz"))
       (sha256
        (base32 "19q128ldi0aspy7vc03r54vrf7wz7l1181x9pbmax8340nbnaz7l"))))
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
    (propagated-inputs
     `(("gpgme" ,gpgme)
       ("qgpgme" ,qgpgme)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
             (when tests? ;; FIXME: These tests fail.
               (invoke "ctest" "-E"
                       "(keyresolvercoretest|newkeyapprovaldialogtest)")))))))
    (home-page "https://invent.kde.org/pim/libkleo")
    (synopsis "KDE PIM cryptographic library")
    (description "@code{libkleo} is a library for Kleopatra and other parts of
KDE using certificate-based crypto.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

(define-public libksieve
  (package
    (name "libksieve")
    (version "21.12.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://kde/stable/release-service/" version
                           "/src/libksieve-" version ".tar.xz"))
       (sha256
        (base32 "1li9cc5y6xbn4m4qa21qmsjd4xzshp67mxwh2nvr17mfs8ray7vd"))
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
                (string-append "# " line))))))))
    (home-page "https://invent.kde.org/pim/libksieve")
    (synopsis "KDE Sieve library")
    (description "Sieve is a language that can be used filter emails.  KSieve
is a Sieve parser and interpreter library for KDE.")
    (license ;; GPL for programs, LGPL for libraries
     (list license:gpl2+ license:lgpl2.0+))))

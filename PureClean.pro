# Add more folders to ship with the application, here
folder_01.source = qml/PureClean
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE432D00B
# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices AllFiles ReadDeviceData PowerMgmt
symbian:ICON=qml/PureClean/logo.svg
CONFIG += qt-components
QT+=MOBILITY
MOBILITY+= systeminfo
SOURCES += main.cpp \
    application.cpp \
    deleteitem.cpp \
    filemodel.cpp \
    asynctask.cpp

include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
symbian:LIBS+=-lbafl -lstarterclient
symbian:DEPLOYMENT+=info
vendorinfo =  "%{\"KolaySoft\"}" \
    ":\"KolaySoft\""
vendor.pkg_prerules = vendorinfo
symbian:DEPLOYMENT += vendor
TARGET=BelleCleaner
DEPLOYMENT.display_name = BelleCleaner
symbian:LIBS+=-lefsrv
MMP_RULES-="DEBUGGABLE_UDEBONLY"
MMP_RULES+="DEBUGGABLE"
HEADERS += \
    application.h \
    deleteitem.h \
    filemodel.h \
    asynctask.h

folder_02.sources = $$PWD/bellecleaner_*.qm
folder_02.path =
DEPLOYMENT += folder_02

$list=system(dir /b $$PWD\\qml\\PureCleaner\\*.qml)
TRANSLATIONS += bellecleaner_en.ts

CODECFORTR = UTF-8
CODECFORSRC = UTF-8
system (lupdate $$files($$PWD/qml/PureClean/*.qml) -ts bellecleaner_en.ts)

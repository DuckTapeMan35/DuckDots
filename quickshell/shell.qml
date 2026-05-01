//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io

import "components"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        Bar {}
    }
}


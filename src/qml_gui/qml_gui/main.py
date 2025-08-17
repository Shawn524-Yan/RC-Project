# filepath: /mnt/e/RC-Project/src/qml_gui/qml_gui/main.py
import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from gui_contorller import Controller
def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_path = os.path.join(os.path.dirname(__file__), "gui.qml")
    controller = Controller()
    engine.rootContext().setContextProperty("controller", controller)
    engine.load(qml_path)
    if not engine.rootObjects():
        print("Failed to load QML file:", qml_path)
        sys.exit(-1)
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
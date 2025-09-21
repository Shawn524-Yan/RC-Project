# controller.py
from PySide6.QtCore import QObject, Slot, Property
from PySide6.QtCore import Signal
class Controller(QObject):
    currentViewChanged = Signal()
    def __init__(self):
        super().__init__()
        self._recording = False
        self._currentView = "none"

    def getCurrentView(self):
        return self._currentView
   
    def setCurrentView(self, value):
        if self._currentView != value:
            self._currentView = value
            self.currentViewChanged.emit()

    currentView = Property(str, getCurrentView, setCurrentView, notify=currentViewChanged)

    @Slot(str)
    def switch_view(self, view_name):
        self.setCurrentView(view_name)
        print(f"Switching to view: {view_name}")
        # 这里可以发布 ROS 2 topic 或更新状态

    @Slot()
    def toggle_recording(self):
        self._recording = not self._recording
        print("Recording:", "Started" if self._recording else "Stopped")

    @Property(bool)
    def recording(self):
        return self._recording

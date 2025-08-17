# controller.py
from PySide6.QtCore import QObject, Slot, Property

class Controller(QObject):
    def __init__(self):
        super().__init__()
        self._recording = False

    @Slot(str)
    def switch_view(self, view_name):
        print(f"Switching to view: {view_name}")
        # 这里可以发布 ROS 2 topic 或更新状态

    @Slot()
    def toggle_recording(self):
        self._recording = not self._recording
        print("Recording:", "Started" if self._recording else "Stopped")

    @Property(bool)
    def recording(self):
        return self._recording

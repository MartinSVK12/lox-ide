package godot

import godot.annotation.RegisterClass
import godot.annotation.RegisterFunction
import godot.api.Button

@RegisterClass
class StopButton: Button() {

    @RegisterFunction
    fun _on_pressed(){
        RunScript.currentThread?.stop()
    }

}

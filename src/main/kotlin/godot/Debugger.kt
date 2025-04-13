package godot

import godot.annotation.RegisterClass
import godot.annotation.RegisterFunction
import godot.api.*
import godot.core.*
import sunsetsatellite.interpreter.sunlite.Environment
import sunsetsatellite.lang.sunlite.Sunlite
import sunsetsatellite.interpreter.sunlite.LoxClass
import sunsetsatellite.interpreter.sunlite.LoxClassInstance

@RegisterClass
class Debugger: Node() {

	var currentBreakpointLine: Int = -1
	var currentBreakpointFile: String? = null
	var currentBreakpointInterpreter: Sunlite? = null
	var currentBreakpointEnv: Environment? = null
	var envs: MutableList<Environment> = mutableListOf()

	// Called when the node enters the scene tree for the first time.
	@RegisterFunction
	override fun _ready() {

	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	@RegisterFunction
	override fun _process(delta: Double) {
		val label = getNode("%DebuggerStatusLabel".asNodePath()) as Label
		if(RunScript.currentThread?.isAlive == true && RunScript.currentInterpreter?.interpreter?.breakpointHit == false) {
			label.setText("Running...")
			label.labelSettings?.setFontColor(Color("40ff40"))
		} else if(RunScript.currentInterpreter == null) {
			label.setText("No program is running.")
			label.labelSettings?.setFontColor(Color("808080"))
			if(currentBreakpointInterpreter != null) {
				_on_resume_button_pressed()
			}
		}
	}

	fun breakpointHit(line: Int, file: String?, sunlite: Sunlite, env: Environment?) {
		(getNode("%DebuggerButton".asNodePath()) as Button).setPressed(true)
		currentBreakpointLine = line
		currentBreakpointFile = file
		currentBreakpointEnv = env
		currentBreakpointInterpreter = sunlite
		val tree = this.getNode("%ProjectStructureTree".asNodePath()) as Tree?
		(tree?.get("load_file".asStringName()) as Callable).call(file)
		val tabs = this.getNode("%ScriptTabs".asNodePath()) as TabContainer?
		val scriptTab = tabs?.getCurrentTabControl() as CodeEdit?
		val stackTraces = getNode("%StackTraces".asNodePath()) as VBoxContainer?
		stackTraces?.getChildren()?.forEach {
			it.queueFree()
		}
		var currentEnv = env
		var i = 0
		while(currentEnv != null) {
			envs.add(currentEnv)
			val traceButton = Button()
			traceButton.setText(currentEnv.toString())
			traceButton.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			traceButton.setMeta("env_index".asStringName(),i)
			traceButton.addThemeStyleboxOverride("focus".asStringName(), StyleBoxEmpty())
			traceButton.pressed.connect(flags = godot.api.Object.ConnectFlags.CONNECT_REFERENCE_COUNTED.id.toInt()) {
				val index = (traceButton.getMeta("env_index".asStringName()) as Long).toInt()
				displayEnvValues(envs[index])
			}
			stackTraces?.callDeferred("add_child".asStringName(),traceButton)
			currentEnv = currentEnv.enclosing
			i++
		}
		env?.let { displayEnvValues(it) }
		scriptTab?.setLineBackgroundColor(line-1, Color(1, 0, 0, 0.25))
		val statusLabel = getNode("%DebuggerStatusLabel".asNodePath()) as Label
		statusLabel.setText("Breakpoint hit at line $line!")
		statusLabel.labelSettings?.setFontColor(Color("ff4040"))
		(getNode("./VBox/Panel/HBoxContainer/ResumeButton".asNodePath()) as Button).disabled = false
	}

	private fun displayEnvValues(env: Environment){
		val envVars = getNode("%EnvVars".asNodePath()) as Tree?
		envVars?.clear()
		val root = envVars?.createItem(null)
		env.values.forEach { (k, v) ->
			val envVar = root?.createChild()
			envVar?.setCollapsed(true)
			envVar?.setText(0,"$k: $v")
			loadValues(envVar, v)
		}
	}

	private fun loadValues(parent: TreeItem?, value: Any?){
		when (value) {
			is LoxClass -> {
				value.staticFields.forEach { (t, u) ->
					val field = parent?.createChild()
					field?.setText(0,"<static> $t: ${u.value}")
					loadValues(field,u.value)
				}
			}
			is LoxClassInstance -> {
				value.fields.forEach { (t, u) ->
					val field = parent?.createChild()
					field?.setText(0,"$t: ${u.value}")
					loadValues(field,u.value)
				}
				val staticSelf = parent?.createChild()
				staticSelf?.setText(0,"<static> self: ${value.clazz}")
				value.clazz?.staticFields?.forEach { (t, u) ->
					val field = staticSelf?.createChild()
					field?.setText(0,"<static> $t: ${u.value}")
					loadValues(field,u.value)
				}
			}
		}

	}

	@RegisterFunction
	fun _on_resume_button_pressed(){
		(getNode("./VBox/Panel/HBoxContainer/ResumeButton".asNodePath()) as Button).disabled = true
		val scriptTab = ((this.getNode("%ScriptTabs".asNodePath()) as TabContainer).getCurrentTabControl() as CodeEdit?)
		val stackTraces = getNode("%StackTraces".asNodePath()) as VBoxContainer?
		val envVars = getNode("%EnvVars".asNodePath()) as Tree?
		stackTraces?.getChildren()?.forEach {
			it.queueFree()
		}
		envVars?.clear()
		scriptTab?.setLineBackgroundColor(currentBreakpointLine-1,Color(0,0,0,0))
		currentBreakpointInterpreter?.interpreter?.continueExecution = true
		currentBreakpointLine = -1
		currentBreakpointFile = null
		currentBreakpointEnv = null
		currentBreakpointInterpreter = null
		envs.clear()
	}

}

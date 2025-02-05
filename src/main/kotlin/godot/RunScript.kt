@file:Suppress("FunctionName")

package godot

import godot.annotation.RegisterClass
import godot.annotation.RegisterFunction
import godot.core.*
import godot.global.GD
import sunsetsatellite.lang.lox.BreakpointListener
import sunsetsatellite.lang.lox.Environment
import sunsetsatellite.lang.lox.LogEntryReceiver
import sunsetsatellite.lang.lox.Lox
import java.io.PrintWriter
import java.io.StringWriter
import kotlin.concurrent.thread


@RegisterClass
class RunScript: Button(), LogEntryReceiver, BreakpointListener {

	companion object {
		var currentThread: java.lang.Thread? = null
		var currentInterpreter: Lox? = null
		var logger: Node? = null

		fun logInfo(s: String) {
			logger?.let {
				Callable(it,"info".asStringName()).callDeferred(s)
			}
		}

		fun logWarn(s: String) {
			logger?.let {
				Callable(it,"warn".asStringName()).callDeferred(s)
			}
		}

		fun logError(s: String) {
			logger?.let {
				Callable(it,"error".asStringName()).callDeferred(s)
			}
		}
		var wasDebug = false
	}

	// Called when the node enters the scene tree for the first time.
	@RegisterFunction
	override fun _ready() {
		logger = getTree()?.getRoot()?.getNode("Logger".asNodePath())
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	@RegisterFunction
	override fun _process(delta: Double) {
		disabled = false
		val file: String? = getTree()?.currentScene?.get("current_file".asStringName()) as String?
		if(file == "" || file == null){
			disabled = true
			return
		}
		if(currentThread?.isAlive == true) {
			(getThemeStylebox("normal".asStringName()) as StyleBoxFlat).bgColor = Color("264d26")
			disabled = true
			(getNode("%StopButton".asNodePath()) as Control).visible = true
			if(wasDebug){
				(getNode("%RunButton".asNodePath()) as Control).visible = false
			} else {
				(getNode("%DebugButton".asNodePath()) as Control).visible = false
			}
		} else {
			currentInterpreter = null
			currentThread = null
			(getThemeStylebox("normal".asStringName()) as StyleBoxFlat).bgColor = Color("222222")
			disabled = false
			(getNode("%StopButton".asNodePath()) as Control).visible = false
			(getNode("%RunButton".asNodePath()) as Control).visible = true
			(getNode("%DebugButton".asNodePath()) as Control).visible = true
		}
	}

	@RegisterFunction
	fun _on_pressed(){
		val tabs = this.getNode("%ScriptTabs".asNodePath()) as TabContainer?
		val currentScriptTab = tabs?.getCurrentTabControl() ?: return
		(currentScriptTab.get("save".asStringName()) as Callable).call()
		val isDebug = getName().toString() == "DebugButton"
		val file: String = currentScriptTab.get("file".asStringName()).toString()
		val folders: Array<String> = (getTree()?.currentScene?.get("folders".asStringName()) as VariantArray<String>).toTypedArray()
		val breakpoints: MutableMap<String,IntArray> = mutableMapOf()
		tabs.getChildren().forEach { node ->
			val tabFile: String = node.get("file".asStringName()).toString()
			val breakpointedLines = (node as CodeEdit).getBreakpointedLines()
			breakpoints[tabFile.split("/").last()] = breakpointedLines.toIntArray().map { it.inc() }.toIntArray()
		}
		if(file != ""){
			currentInterpreter = Lox(arrayOf(file,folders.joinToString(";"),""))
			currentThread = thread(
				start = true,
				name = "Lox Interpreter",
			) {
				currentInterpreter!!.logEntryReceivers.add(this)
				currentInterpreter!!.breakpointListeners.add(this)
				GdLoxGlobals.registerGlobals(currentInterpreter!!)
				if(isDebug) currentInterpreter!!.breakpoints = breakpoints
				currentInterpreter!!.start()
			}
			currentThread!!.setUncaughtExceptionHandler { t, e ->
				if (e is ThreadDeath) return@setUncaughtExceptionHandler
				logError("Exception in thread \"" + t.name + "\" ")
				val sw = StringWriter()
				e.printStackTrace(PrintWriter(sw))
				val s = sw.toString()
				logError(s)
			}
			wasDebug = isDebug
			(getNode("%TerminalWindow".asNodePath()) as TextEdit).setText("")
			(getNode("%TerminalButton".asNodePath()) as Button).setPressed(true)
		}
	}

	override fun info(message: String) {
		logInfo(message)
	}

	override fun warn(message: String) {
		logWarn(message)
	}

	override fun err(message: String) {
		logError(message)
	}

	override fun breakpointHit(line: Int, file: String?, lox: Lox, env: Environment) {
		GD.print("Breakpoint hit on line $line!")
		godot.Thread.setThreadSafetyChecksEnabled(false)
		(getNode("%Debugger".asNodePath()) as Debugger).breakpointHit(line, file, lox, env)
		godot.Thread.setThreadSafetyChecksEnabled(true)
	}
}

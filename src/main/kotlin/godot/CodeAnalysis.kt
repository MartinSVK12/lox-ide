package godot

import godot.annotation.RegisterClass
import godot.annotation.RegisterFunction
import godot.annotation.RegisterSignal
import godot.api.CodeEdit
import godot.api.Node
import godot.api.TabContainer
import godot.core.*
import godot.global.GD
import sunsetsatellite.lang.sunlite.Expr
import sunsetsatellite.lang.sunlite.LogEntryReceiver
import sunsetsatellite.lang.sunlite.Sunlite
import sunsetsatellite.lang.sunlite.Stmt
import sunsetsatellite.lang.sunlite.SymbolFinder
import sunsetsatellite.lang.sunlite.Token
import sunsetsatellite.lang.sunlite.TypeCollector
import java.io.PrintWriter
import java.io.StringWriter
import java.lang.Thread
import kotlin.concurrent.thread

@RegisterClass
class CodeAnalysis: Node() {

    companion object {
        var inProgress = false
        var lastAnalysis: Pair<List<Token>,List<Stmt>>? = null
    }

    @RegisterSignal("errors","tokens")
    val analysisCompleted by signal2<VariantArray<String>,VariantArray<Dictionary<Any?,Any?>>>()
    
    // Called when the node enters the scene tree for the first time.
    @RegisterFunction
    override fun _ready() {
        
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    @RegisterFunction
    override fun _process(delta: Double) {
        
    }

    fun analysisFinished(errors: List<String>, result: Pair<List<Token>,List<Stmt>>? = null){
        inProgress = false
        lastAnalysis = result
        val tokens = result?.first?.map { dictionaryOf<Any?,Any?>(
            "name" to it.type.name,
            "type" to it.type.group.name,
            "lexeme" to it.lexeme,
            "file" to (it.file ?: ""),
            "line" to it.line,
            "pos" to Vector2i(it.pos.start,it.pos.end))
        }?.toVariantArray()
        godot.api.Thread.setThreadSafetyChecksEnabled(false)
        analysisCompleted.emit(errors.toVariantArray(), tokens ?: variantArrayOf())
        godot.api.Thread.setThreadSafetyChecksEnabled(true)
    }

    @RegisterFunction
    fun _on_timer_timeout() {
        if(inProgress) return
        val file: String = ((this.getNode("%ScriptTabs".asNodePath()) as TabContainer).getCurrentTabControl()?.get("file".asStringName()) ?: "").toString()
        if(file == "") return
        val scriptWindow = (this.getNode("%ScriptTabs".asNodePath()) as TabContainer).getCurrentTabControl() ?: return
        val code: String = ((scriptWindow as CodeEdit).text)
        val folders: Array<String> = (getTree()?.currentScene?.get("folders".asStringName()) as VariantArray<String>).toTypedArray()
        CodeAnalysisThread(this).analyze(file,folders,code)
    }

    @RegisterFunction
    fun _on_symbol_hovered(symbol: String, line: Int, column: Int): String {
        //GD.print("Hovered $symbol on line $line, column $column")
        //GD.print("Last analysis available: ${lastAnalysis != null}")
	    lastAnalysis?.let {
            val foundElement = SymbolFinder(symbol, line+1, column).find(it.second)
            if(foundElement is Expr){
                return foundElement.getExprType().toString()
            }
        }
        return "unknown"
    }

    class CodeAnalysisThread(val analysis: CodeAnalysis) : LogEntryReceiver {

        private val errors: MutableList<String> = ArrayList()
        private var thread: Thread? = null

        override fun info(message: String) {

        }

        override fun warn(message: String) {

        }

        override fun err(message: String) {
            errors.add(0, message)
        }

        fun analyze(file: String, loadPath: Array<String> = arrayOf(), code: String? = null) {
            inProgress = true
            thread = thread(
                start = true,
                name = "Sunlite Code Analysis",
            ) {
                val sunlite = Sunlite(arrayOf(file,loadPath.joinToString(";")))
                sunlite.logEntryReceivers.add(this)
                //GdLoxGlobals.registerGlobals(sunlite)
                val result = sunlite.parse(code)
                if(result == null){
                    analysis.analysisFinished(errors)
                    return@thread
                } else {
                    analysis.analysisFinished(errors,result.first to result.second)
                }
            }
            thread!!.setUncaughtExceptionHandler { t, e ->
                if (e is ThreadDeath) return@setUncaughtExceptionHandler
                val sw = StringWriter()
                e.printStackTrace(PrintWriter(sw))
                val s = sw.toString()
                err(s)
                analysis.analysisFinished(errors)
            }
        }

    }
}

package godot

import godot.annotation.RegisterClass
import godot.annotation.RegisterFunction
import godot.annotation.RegisterSignal
import godot.core.*
import godot.global.GD
import sunsetsatellite.lang.lox.LogEntryReceiver
import sunsetsatellite.lang.lox.Lox
import sunsetsatellite.lang.lox.Stmt
import sunsetsatellite.lang.lox.Token
import java.io.PrintWriter
import java.io.StringWriter
import java.lang.Thread
import kotlin.concurrent.thread

@RegisterClass
class CodeAnalysis: Node() {

    companion object {
        var inProgress = false
    }

    @RegisterSignal
    val analysisCompleted by signal2<VariantArray<String>,VariantArray<Dictionary<Any?,Any?>>>("errors","tokens")
    
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
        val tokens = result?.first?.map { dictionaryOf<Any?,Any?>(
            "name" to it.type.name,
            "type" to it.type.group.name,
            "lexeme" to it.lexeme,
            "file" to (it.file ?: ""),
            "line" to it.line,
            "pos" to Vector2i(it.pos.start,it.pos.end))
        }?.toVariantArray()
        godot.Thread.setThreadSafetyChecksEnabled(false)
        analysisCompleted.emit(errors.toVariantArray(), tokens ?: variantArrayOf())
        godot.Thread.setThreadSafetyChecksEnabled(true)
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
                name = "Lox Code Analysis",
            ) {
                val lox = Lox(arrayOf(file,loadPath.joinToString(";")))
                lox.logEntryReceivers.add(this)
                GdLoxGlobals.registerGlobals(lox)
                val result = lox.parse(code)
                result ?: analysis.analysisFinished(errors)
                analysis.analysisFinished(errors,result)
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

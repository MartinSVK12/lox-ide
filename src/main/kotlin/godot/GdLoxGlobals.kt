package godot

import sunsetsatellite.lang.lox.Interpreter
import sunsetsatellite.lang.lox.Lox
import sunsetsatellite.lang.lox.LoxCallable

object GdLoxGlobals {

    fun registerGlobals(lox: Lox) {
        lox.globals["print"] = object : LoxCallable {
            override fun call(interpreter: Interpreter, arguments: List<Any?>?): Any? {
                RunScript.logInfo(arguments?.get(0).toString())
                return null
            }

            override fun arity(): Int {
                return 1
            }

            override fun signature(): String {
                return "print"
            }

            override fun toString(): String {
                return "<global fn 'print'>"
            }
        }

        lox.globals["printerr"] = object : LoxCallable {
            override fun call(interpreter: Interpreter, arguments: List<Any?>?): Any? {
                RunScript.logError(arguments?.get(0).toString())
                return null
            }

            override fun arity(): Int {
                return 1
            }

            override fun signature(): String {
                return "printerr"
            }

            override fun toString(): String {
                return "<global fn 'printerr'>"
            }
        }
    }

}
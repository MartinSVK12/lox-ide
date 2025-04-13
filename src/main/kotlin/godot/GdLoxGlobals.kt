package godot

import sunsetsatellite.interpreter.sunlite.Interpreter
import sunsetsatellite.lang.sunlite.Sunlite
import sunsetsatellite.interpreter.sunlite.LoxCallable
import sunsetsatellite.lang.sunlite.Type

object GdLoxGlobals {

    fun registerGlobals(sunlite: Sunlite) {
        sunlite.globals["print"] = object : LoxCallable {
            override fun call(interpreter: Interpreter, arguments: List<Any?>?, typeArguments: List<Type>): Any? {
                RunScript.logInfo(arguments?.get(0).toString())
                return null
            }
            override fun arity(): Int {
                return 1
            }

            override fun typeArity(): Int {
                return 0
            }

            override fun signature(): String {
                return "print(o: any|nil)"
            }

            override fun varargs(): Boolean {
                return false
            }

            override fun toString(): String {
                return "<global fn 'print'>"
            }
        }

        sunlite.globals["printerr"] = object : LoxCallable {
            override fun call(interpreter: Interpreter, arguments: List<Any?>?, typeArguments: List<Type>): Any? {
                RunScript.logError(arguments?.get(0).toString())
                return null
            }

            override fun arity(): Int {
                return 1
            }

            override fun typeArity(): Int {
                return 0
            }

            override fun signature(): String {
                return "printerr(o: any|nil)"
            }

            override fun varargs(): Boolean {
                return false
            }

            override fun toString(): String {
                return "<global fn 'printerr'>"
            }
        }
    }

}
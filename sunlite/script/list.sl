fun inc(arr: array): array{
    resize(sizeOf(arr)+1,arr);
    return arr;
}

fun dec(arr: array): array{
    resize(sizeOf(arr)-1,arr);
    return arr;
}

class List {
    
    var _l: number = 0;
    var _a: array = arrayOf(10);
    
    init(){
        
    }
    
    fun size(): number { return this._l; }
    
    fun isEmpty(): boolean { return size() == 0; }
    
    fun insert(index, o): boolean {
        if(this._l <= index) return false;
        if(this._l > sizeOf(this._a)){
            inc(this._a);
        }
        //this._a[this._l] = this._a[this._l-1]
        for(var i = this._l; i > index; i = i - 1){
            //print(this._a[i]);
            this._a[i] = this._a[i - 1];
        }
        this._a[index] = o;
        this._l = this._l + 1;
        return true;
    }
    
    fun add(o): boolean {
        if(this._l > sizeOf(this._a)){
            inc(this._a);
        }
        this._a[this._l] = o;
        this._l = this._l + 1;
        return true;
    }
    
    fun remove(o): boolean {
        if(!this.contains(o)) return false;
        var index = this.indexOf(o);
        return this.removeAt(index);
    }
    
    fun removeAt(index): boolean {
        if(index != -1){
            this._a[index] = nil;
            for(var i = index; i < this._l; i = i + 1){
                this._a[i] = this._a[i + 1];
            }
            this._l = this._l - 1;
            dec(this._a);
            return true;
        }
        return false;
    }
    
    fun get(i): any|nil{
        return this._a[i];
    }
    
    fun indexOf(o): number {
        for(var i = 0; i < this._l; i = i + 1){
            if(this.get(i) == o){
                return i;
            }
        }
        return -1;
    }

    fun contains(o): boolean {
        for(var i = 0; i < this._l; i = i + 1){
            if(this.get(i) == o){
                return true;
            }
        }
        return false;
    }

    
    fun forEach(callback) {
        for(var i = 0; i < this._l; i = i + 1){
            callback(this.get(i));
        }
    }

    fun forEachIndexed(callback) {
        for(var i = 0; i < this._l; i = i + 1){
            callback(i,this.get(i));
        }
    }
}

var list = List();
list.add(5);
list.add(true);
list.removeAt(1);
print(list);
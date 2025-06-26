class A {
    init(str) {
        this.initString = str;
        this.n = 3;
        print(str);
    }
    
    fun do(something) {
        this.n = this.n * something;
    }
}

var a = A("hi");
print(a.do(3));
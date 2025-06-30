var arr = arrayOf(5);

fun removeAt(a,i) {
    a[i] = nil;
}

arr[1] = "yeet";
print(arr[1]);
removeAt(arr,1);
print(arr[1]);
1.How to organize the testbench:

Part_2:

//Input_feeding
使用三層for迴圈，每一層迴圈中的變數會從0數到2^N-1。
而在最內層的迴圈利用15個@(negedge clk)的方式在負緣驅動的時候將i,j,k三個變數以及當下的Mode丟給RTL module當作輸入。

//Output result comparison
因為pipeline stage的關係，等待兩個負緣驅動後，在接下來的正緣驅動才會有輸出產生。
此時先用while判斷當下的輸入為第幾個pattern(pattern_i)，看看是否尚小於全部的pattern總數(pattern_num)。
若while判斷為true，則會進行Result_RTL_smart以及Result_RTL_lut16的比較，
若兩module的輸出一樣則回到while再次判斷，若不一樣則用$display顯示第幾個pattern出錯以及使用$finish來終止程序。
若while判斷為否，則表示所有比對均正確。



Part_3:
與Part_2的建立方式雷同，不過在input feeding的部分使用了四層for迴圈來表示P,S,D,Mode全部的可能組合。

Part_4:
將part_3的input feeding以及output comparison RTL block搬移到task裡面即可。其中因為side effect的關係，不太需要對其他地方進行修改。


2. How to find out the all 256 functions:
將題目給的表倒過來之後可以利用K-map的方式進行畫簡，找出最後的function。


----------------------------------------------------------------
TA feedback:
part1:(-0.5)
非參數化(8'hxx)
part2:(-0.5)
rtl非參數化
part3:(-0.5)
rtl非參數化(8'hxx)



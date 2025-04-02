# Sample Code Referenced in How to Develop Client Side Validations without Page Submit
This markdown contains sameple code for the video below. 

- It is reccomended to watch this video first. [https://youtu.be/7-y9f7zEWSE?si=dtAu9viAXFOi7e-i](https://youtu.be/7-y9f7zEWSE?si=dtAu9viAXFOi7e-i)

- Code shown at 00:56 highlighting the core javscript on the page level to be called. 
```
<script type="text/javascript">
  //this function inputs a number formatted as a currency and strips out all the $ and comma for proper number processing.
  function toCN(currency){
    console.log("Running toCN function on input: "+currency);
        try {
        return Number(currency.replace(/,/g,'').replace(/\$|,/g,''));
        }
        catch (error) {
        console.error(error);
        }
  }

  function toCurrency(raw_currency) {
    console.log("Running toCurrency");
    try {
        // Create our number formatter.
        let formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        // These options are needed to round to whole numbers if that's what you want.
        //minimumFractionDigits: 0, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
        //maximumFractionDigits: 0, // (causes 2500.99 to be printed as $2,501)
        });

       return formatter.format(raw_currency); 
    }
    catch (error) {
        console.error(error);
    }
  }

  function hasLetters(v_field){
      let regExp = /[a-zA-Z]/g;
      if(regExp.test(v_field)){
     /* do something if letters are found in your string */
       return true;
      } else {
       /* do something if letters are not found in your string */
      }
  }

  function isNegative(v_field){
      if (v_field < 0) {
          return true;
        }
        return false;
  }

</script>
```

- Code shown at 2:14 dynamic action javascript validation
```
console.log("P2_Q2_GATE Validations Firing");
let v_tempVar = toCN($v("P2_Q2_GATE"));

//Make sure numeric           
if(hasLetters(v_tempVar)){
  apex.message.alert("Your Q2 Gate contains non-numeric characters. Please try again.");
  $s("P2_Q2_GATE","");
} 

//Make sure positive number
if (isNegative(v_tempVar)){
 apex.message.alert("Your Q2 Gate must be a positive number. Please try again.");
  $s("P2_Q2_GATE","");   
}

//Has to be greater than Q1_Gate
if (v_tempVar < toCN($v("P2_Q1_GATE"))){
 apex.message.alert("Your Q2 Gate must be > than your q1 gate. Please try again.");
  $s("P2_Q2_GATE","");   
}

//Has to be less than Q4_Gate
if (v_tempVar > toCN($v("P2_Q4_GATE"))){
 apex.message.alert("Your Q2 Gate must be < than your q4 gate. Please try again.");
  $s("P2_Q2_GATE","");   
}

```
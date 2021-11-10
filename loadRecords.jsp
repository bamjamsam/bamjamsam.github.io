<h1>LISTENER</h1>
<p>Here's the data sent from SAC:</p>
<p id="sac"></p>
<p id="jsp"></p>

	</div>
<script>
//add an EventListener to handle the postMessage call from SAC
window.addEventListener('message', function(e) {
//var event,obj, i, x = "";
var obj;
//set obj to the JSON object passed in the message
obj = JSON.parse(e.data);
//display the number of records received from SAC
document.getElementById("sac").innerHTML = obj.data.length +" records passed from SAC";
//call the getPost() function and pass in the JSON object
getPost(obj);
}, false);
//use this function to send the JSON object to the JSP page and listen for the results of the
upload
function getPost(obj){
var loadData=new XMLHttpRequest();
loadData.onreadystatechange=function()
{
if (loadData.readyState==4 && loadData.status==200)
{
document.getElementById("jsp").innerHTML = loadData.responseText;
window.parent.postMessage(loadData.responseText,"*");
}
}
loadData.open("POST","/cv/loadRecords.jsp",true);
loadData.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
loadData.send("data="+JSON.stringify(obj));
}
</script>

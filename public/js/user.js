window.onload = function() {

    $('tr.weigh-in').each( function() {

        var id = $(this).find('.id').text();

        $(this).find('.delete-weight').click(function() {
            console.log('clicked', id)
            $.ajax({
                type: 'DELETE',
                url: '/weight/' + id,
                success: function() {console.log('done')}
            })
        })
    })

var labels = [];
$('td.time').each(
    function() {labels.push($(this).text())}
)
var data = [];
$('td.weight').each(
    function() {
        var weight = $(this).text();
        data.push(parseFloat(weight.substring(0, weight.length - 3)))
    }
)

var lineChartData = {
    
    // console.log('array', $('div'));

    
	labels :labels.reverse(),

	datasets : [
		{
            label: '<%= data[:name] %>',
            bezierCurve: false,
            pointColor: "100,0,56,1)",
            fillColor : "100,0,56,0.5)",
            strokeColor : "100,0,56,0.8)",
            highlightFill : "100,0,56,0.75)",
            highlightStroke : "100,0,56,1)",
			data : data.reverse()
		}
	]

}
	var ctx = document.getElementById("canvas").getContext("2d");
    
    window.weightLine = new Chart(ctx).Line(lineChartData, {
        responsive : true
    });
    


}

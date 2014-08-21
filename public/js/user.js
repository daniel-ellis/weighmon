window.onload = function() {
    var deleteWeight = function() {
        $('#deleteConfirmModal').modal({})
        // $('.delete-result-confirm').click(function() {
        //     console.log('clicked', id)
        //     // $.ajax({
        //     //     type: 'DELETE',
        //     //     url: '/weight/' + id,
        //     //     success: function() {console.log('done')}
        //     // })
        // })
    }
    $('tr.weigh-in').each(function() {
        var id = $(this).find('.id').text();
        $(this).find('.delete-weight').click(deleteWeight)
    })
    var labels = [];
    $('td.time').each(function() {
        labels.push($(this).text())
    })
    var data = [];
    $('td.weight').each(function() {
        var weight = $(this).text();
        data.push(parseFloat(weight.substring(0, weight.length - 3)))
    })
    var lineChartData = {
        labels: labels.reverse(),
        datasets: [{
            label: '<%= data[:name] %>',
            bezierCurve: false,
            pointColor: "rgba(90,40,56,1)",
            fillColor: "rgba(90,40,56,0.5)",
            strokeColor: "rgba(90,40,56,0.8)",
            highlightFill: "rgba(90,40,56,0.75)",
            highlightStroke: "rgba(90,40,56,1)",
            data: data.reverse()
        }]
    }
    var ctx = document.getElementById("canvas").getContext("2d");
    window.weightLine = new Chart(ctx).Line(lineChartData, {
        responsive: true
    });
}
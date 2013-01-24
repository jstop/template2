require.config({
  paths: {
    'jquery': 'lib/jquery-1.7.1.min',
    'jquery-ui': 'lib/jquery-ui-1.8.21.min',
    'jquery-validate': 'lib/jquery.validate.min',
    'bootstrap': 'lib/bootstrap.min',
    'underscore': 'lib/underscore',
    'domReady': 'lib/domReady',
    'Handlebars': 'lib/Handlebars',    
    'knockout': 'lib/knockout-2.1.0',
    'dataTables': 'lib/jquery.dataTables.min',
    'datetimepicker': 'lib/bootstrap-datetimepicker.min',
    'token-input': 'lib/jquery.tokeninput'
  }
});

require(['domReady', 'jquery', 'bootstrap', 'Handlebars', 'jquery-ui', 'datetimepicker', 'token-input'], 
    function(domReady, $,  Handlebars, tmpl, ui) {
      domReady(function () {
        //registerPartials();
        //renderLayout();
        //loadItem();
        $("#token-input").tokenInput("/tags_service");
        $('#datetimepicker1').datetimepicker({
          language: 'en'
        });
        $('#datetimepicker2').datetimepicker({
          language: 'en',
          pick12HourFormat: true,
          pickDate: false
        });
      });

      function registerPartials() {
        //Handlebars.registerPartial("project-list-item", Handlebars.templates["project_list_item"]);
      }
      
      function renderLayout() {
        //var html = Handlebars.templates["layout"]();
        //$('.container').html(html);
        //$('.top-tabs').tabs();
        $('body').css('display', 'block');
      }

      function loadItem() {
        //var itemHtml = Handlebars.templates["project_list_item"]();
        $('body').append(itemHtml);
      }
      function docReady() {
        $(document).ready(function () {
          console.log("hfello");
          $("#token-input").tokenInput("/tags_service");
        });
      }
    }
);

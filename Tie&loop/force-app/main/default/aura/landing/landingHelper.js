({
    update: function(component) {
        var completedSections;

        var sections = component.get('v.data');

        sections.forEach(function(section) {
            if (!$A.util.isEmpty(section.status)) {
                if ($A.util.isEmpty(completedSections)) {
                    completedSections = 0;
                }

                if ('completed' == section.status) {
                    completedSections++;
                }
            }
        });

        component.set('v.completedSections', completedSections);
    }
})
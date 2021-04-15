({
    hide: function(component, event, helper) {
        component.set('v.hidden', true);

        var thumbsUp = component.find('thumbs-up');
        var stars = component.find('star');

        $A.util.removeClass(thumbsUp, 'strike-animation_entrance');

        stars.forEach(function (star) {
            $A.util.removeClass(star, 'strike-animation__star_show');
        });
    },
    show: function(component, event, helper) {
        component.set('v.hidden', false);

        setTimeout($A.getCallback(function () {
            var thumbsUp = component.find('thumbs-up');
            var stars = component.find('star');

            $A.util.addClass(thumbsUp, 'strike-animation_entrance');

            stars.forEach(function (star) {
                $A.util.addClass(star, 'strike-animation__star_show');
            });
        }), 100);
    }
})
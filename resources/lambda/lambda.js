'use strict';

exports.hello = async (event, context) => {
    return {
	statusCode: 200,
	headers: {
	    'Content-Type': 'text/plain; charset=utf-8'
	},
	body: 'Hello.'
    };
}

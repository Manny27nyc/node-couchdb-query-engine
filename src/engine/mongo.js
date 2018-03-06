import Engine from '../engine';

const mongo = new Engine();

// Comparision

const rules = [
    'eq', 'ne', 'gt', 'gte', 'lt', 'lte', 'in', 'nin', 'or', 'and', 'nor', 'not', 'exists', 'type', 'mod', 'regex', 'all', 'elem-match', 'size'
];

rules.forEach(rule => {
    mongo.append2(require(`../rules/${rule}`).default);
});


/**
 * Test whether or not data matches query
 *
 * @param {Object} data - Data object to match
 * @param {Object} query - Query object
 * @returns {*}
 */
export function test(data, query) {
    return mongo.test(data, query);
}

/**
 * Filter out data using a qquery
 *
 * @param {Object} data - Key value object contains values to filter
 * @param {Object} query - Query object
 * @returns {Array.<*>}
 */
export function parseQuery(data, query) {
    if (!query['selector']) {
        throw new Error('Query needs a selector field');
    }

    const result = [];

    for (const key in data) {
        if (data.hasOwnProperty(key)) {
            const value = data[key];

            const test = mongo.test(value, query['selector']);

            if (test) {
                result.push({
                    key,
                    value
                });
            }

        }
    }

    let skip = query['skip'] | 0;
    let limit = query['limit'] | result.length;


    return result.slice(skip, limit);

}

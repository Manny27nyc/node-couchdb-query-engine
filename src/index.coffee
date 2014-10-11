
{ resolve } = require 'rus-diff'

arrize = (a) -> if Array.isArray(a) then a else [ a ]

ev = (d, q) ->
  r = true
  for k, v of q
    s = switch k

      # Logical ops
      when '$and' then v.reduce ((p, c) -> p and ev(d, c)), true
      when '$or' then v.reduce ((p, c) -> p or ev(d, c)), false
      when '$nor' then v.reduce ((p, c) -> p and not ev(d, c)), true
      when '$not' then not ev(d, v)

      # Comparison ops
      when '$eq' then d is v
      when '$ne' then d isnt v
      when '$lt' then d < v
      when '$lte' then d <= v
      when '$gt' then d > v
      when '$gte' then d >= v
      when '$in' then da = arrize(d); v.some (e) -> e in da
      when '$nin' then da = arrize(d); v.every (e) -> e not in da

      # Element query ops
      when '$exists' then not (v ^ d?)
      when '$type' then typeof d is v # TODO: do it right

      # Evaluation query ops
      when '$mod' then (d % v[0]) is v[1]
      when '$regex' then d.match(new RegExp(v, q.$options))?
      when '$options' then true # HACK
      when '$text' then false
      when '$where' then v d # TODO: security

      # TODO: Geospatial ops

      # Array query ops
      when '$all' then da = arrize(d); v.every (e) -> e in da
      when '$elemMatch' then Array.isArray(d) and d.some (e) -> ev(e, v)
      when '$size' then v is (if Array.isArray(d) then d.length else 0)

      else
        unless k[0] is '$'
          [ dvp, dk ] = resolve d, k
          if dk.length is 1 # ...is resolved
            ev dvp[dk[0]], v
          else
            ev null, v # we can match $exists false.
        else
          throw new Error "#{k} operator is not supported."

    # console.log JSON.stringify { k, v, q, r, s }

    r = r and s

    break unless r
  r

module.exports = {
  ev
}

module LTVModelsBase

# Interface exports
export AbstractModel, AbstractCost, ModelAndCost,f,
dc,calculate_cost,calculate_final_cost,
fit_model, predict, df,costfun, LTVStateSpaceModel,
SimpleLTVModel, covariance

export rms, sse, nrmse


rms(x)      = sqrt(mean(x.^2))
sse(x)      = x⋅x
nrmse(y,yh) = 100 * (1-rms(y-yh)./rms(y-mean(y)))

# Model interface ====================================
"""
Model interface, implement the following functions\n
see also `AbstractCost`, `ModelAndCost`
```
fit_model(::Type{AbstractModel}, batch::Batch)::AbstractModel

predict(model::AbstractModel, x, u)

function df(model::AbstractModel, x, u, I::UnitRange)
    return fx,fu,fxx,fxu,fuu
end
```
"""
abstract type AbstractModel end

abstract type LTVModel <: AbstractModel end

abstract type LTVStateSpaceModel <: LTVModel end

mutable struct SimpleLTVModel{T} <: LTVStateSpaceModel
    At::Array{T,3}
    Bt::Array{T,3}
    extended::Bool
end
function SimpleLTVModel{T}(At::Array{T,3},Bt::Array{T,3},extend::Bool)
    if extend
        At = cat(3,At,At[:,:,end])
        Bt = cat(3,Bt,Bt[:,:,end])
    end
    return SimpleLTVModel{T}(At,Bt,extend)
end

SimpleLTVModel(At,Bt,extend::Bool) = SimpleLTVModel{eltype(At)}(At,Bt,extend)


"""
    model = fit_model(::Type{AbstractModel}, x,u)::AbstractModel

Fits a model to data
"""
function fit_model(::Type{AbstractModel}, x,u)::AbstractModel
    error("This function is not implemented for your type")
    return model
end

"""
    fit_model!(model::AbstractModel, x,u)::AbstractModel

Refits a model to new data
"""
function fit_model!(model::AbstractModel, x,u)::AbstractModel
    error("This function is not implemented for your type")
    return model
end

"""
    xnew = predict(model::AbstractModel, x, u, i)

Predict the next state given the current state and action
"""
function predict(model::AbstractModel, x, u, i)
    error("This function is not implemented for your type")
    return xnew
end


"""
    fx,fu,fxx,fxu,fuu = df(model::AbstractModel, x, u)

Get the linearized dynamics at `x`,`u`
"""
function df(model::AbstractModel, x, u)
    error("This function is not implemented for your type")
    return fx,fu,fxx,fxu,fuu
end

function covariance(model::AbstractModel, x, u)
    cov(x[:,2:end]-predict(model, x, u)[:,1:end-1], 2)
end
# Model interface ====================================


# Cost interface ====================================
"""
Cost interface, implement the following functions\n
see also `AbstractModel`, `ModelAndCost`
```
function calculate_cost(::Type{AbstractCost}, x::AbstractVector, u)::Number

function calculate_cost(::Type{AbstractCost}, x::AbstractMatrix, u)::AbstractVector

function calculate_final_cost(::Type{AbstractCost}, x::AbstractVector)::Number

function dc(::Type{AbstractCost}, x, u)
    return cx,cu,cxx,cuu,cxu
end
```
"""
abstract type AbstractCost end

function calculate_cost(c::AbstractCost, x::AbstractVector, u)::Number
    error("This function is not implemented for your type")
    return c
end

function calculate_cost(c::AbstractCost, x::AbstractMatrix, u)::AbstractVector
    error("This function is not implemented for your type")
    return c
end

function calculate_final_cost(c::AbstractCost, x::AbstractVector)::Number
    error("This function is not implemented for your type")
    return c
end

function dc(c::AbstractCost, x, u)
    error("This function is not implemented for your type")
    return cx,cu,cxx,cuu,cxu
end
# Cost interface ====================================


"""
1. Define types that implement the interfaces `AbstractModel` and `AbstractCost`.
2. Create object modelcost = ModelAndCost(model, cost)
3. Run macro @define_modelcost_functions(modelcost). This macro defines the following functions
```
f(x, u, i)  = f(modelcost, x, u, i)
fT(x)       = fT(modelcost, x)
df(x, u, I) = df(modelcost, x, u, I)
```
see also `AbstractModel`, `AbstractCost`
"""
type ModelAndCost
    model::AbstractModel
    cost::AbstractCost
end

function f(modelcost::ModelAndCost, x, u, i)
    predict(modelcost.model, x, u, i)
end

function costfun(modelcost::ModelAndCost, x, u)
    calculate_cost(modelcost.cost, x, u)
end

"""
    fx,fu,fxx,fxu,fuu,cx,cu,cxx,cxu,cuu = df(modelcost::ModelAndCost, x, u)

Get the linearized dynamics and cost at `x`,`u`
"""
function df(modelcost::ModelAndCost, x, u)
    fx,fu,fxx,fxu,fuu = df(modelcost.model, x, u)
    cx,cu,cxx,cuu,cxu = dc(modelcost.cost, x, u)
    return fx,fu,fxx,fxu,fuu,cx,cu,cxx,cxu,cuu
end




end # module

# TODO: move this to document

"""
    AbstractRegister{B, T}

abstract type that registers will subtype from. `B` is the batch size, `T` is the
data type.

## Required Properties

|    Property    |                                                     Description                                                      |     default      |
|:--------------:|:--------------------------------------------------------------------------------------------------------------------:|:----------------:|
| `nqubits(reg)`  | get the total number of qubits.                                                                                     |                  |
| `nactive(reg)` | get the number of active qubits.                                                                                     |                  |
| `nremain(reg)` | get the number of remained qubits.                                                                                   | nqubits - nactive |
| `nbatch(reg)`  | get the number of batch.                                                                                             | `B`              |
| `state(reg)`   | get the state of this register. It always return the matrix stored inside.                                           |                  |
| `statevec(reg)`| get the raveled state of this register.                                  .                                           |                  |
| `hypercubic(reg)`| get the hypercubic form of this register.                                  .                                       |                  |
| `eltype(reg)`  | get the element type stored by this register on classical memory. (the type Julia should use to represent amplitude) | `T`              |
| `copy(reg)`    | copy this register.                                                                                                  |                  |
| `similar(reg)` | construct a new register with similar configuration.                                                                 |                  |

## Required Methods

### Multiply

    *(op, reg)

define how operator `op` act on this register. This is quite useful when
there is a special approach to apply an operator on this register. (e.g
a register with no batch, or a register with a MPS state, etc.)

!!! note

    be careful, generally, operators can only be applied to a register, thus
    we should only overload this operation and do not overload `*(reg, op)`.

### Pack Address

pack `addrs` together to the first k-dimensions.

#### Example

Given a register with dimension `[2, 3, 1, 5, 4]`, we pack `[5, 4]`
to the first 2 dimensions. We will get `[5, 4, 2, 3, 1]`.

### Focus Address

    focus!(reg, range)

merge address in `range` together as one dimension (the active space).

#### Example

Given a register with dimension `(2^4)x3` and address [1, 2, 3, 4], we focus
address `[3, 4]`, will pack `[3, 4]` together and merge them as the active
space. Then we will have a register with size `2^2x(2^2x3)`, and address
`[3, 4, 1, 2]`.

## Initializers

Initializers are functions that provide specific quantum states, e.g zero states,
random states, GHZ states and etc.

    register(::Type{RT}, raw, nbatch)

an general initializer for input raw state array.

    register(::Val{InitMethod}, ::Type{RT}, ::Type{T}, n, nbatch)

init register type `RT` with `InitMethod` type (e.g `Val{:zero}`) with
element type `T` and total number qubits `n` with `nbatch`. This will be
auto-binded to some shortcuts like `zero_state`, `rand_state`, `randn_state`.
"""
abstract type AbstractRegister{B, T} end


##############
## Interfaces
##############

# nqubits
# nactive
nremain(r::AbstractRegister) = nqubits(r) - nactive(r)
nbatch(r::AbstractRegister{B}) where B = B
eltype(r::AbstractRegister{B, T}) where {B, T} = T

basis(r::AbstractRegister) = basis(nqubits(r))

import Base: +, -, kron

for op in [:+, :-]
    @eval function ($op)(lhs::RT, rhs::AbstractRegister{B}) where {B, RT <: AbstractRegister{B}}
        register(RT, ($op)(state(lhs), state(rhs)), Int(B))
    end
end

function kron(lhs::RT, rhs::AbstractRegister{B}) where {B, RT <: AbstractRegister{B}}
    register(RT, kron(state(rhs), state(lhs)), Int(B))
end

import Base: normalize!

"""
    normalize!(r::AbstractRegister) -> AbstractRegister

Return the register with normalized state.
"""
normalize!(r::AbstractRegister) = throw(MethodError(:normalize!, r))

"""
    statevec(r::AbstractRegister) -> AbstractArray

Return the raveled state (vector) form of this register.                                  .                                           |                  |
"""
function statevec end

"""
    hypercubic(r::AbstractRegister) -> AbstractArray

Return the hypercubic form (high dimensional tensor) of this register.                                  .                                       |                  |
"""
function hypercubic end

# function ghz(num_bit::Int; x::DInt=zero(DInt))
#     v = zeros(DefaultType, 1<<num_bit)
#     v[x+1] = 1/sqrt(2)
#     v[flip(x, bmask(1:num_bit))+1] = 1/sqrt(2)
#     return v
# end

mutable struct ActionNode
    r::Float64
    pind::Int           # index of parent belief node
    children::UnitRange{Int64}
    ai::Int     # which action does this correspond to

    pab::Float64        # P(a | b)
    L::Float64
    U::Float64

    function ActionNode(r, pind, children, ai, L, U)
        new(r, pind, children, ai, 1.0, L, U)
    end
end


mutable struct BeliefNode{B}
    b::B
    ind::Int
    pind::Int       # index of parent node

    oi::Int         # index of observation corresponding with this belief
    po::Float64     # probability of seeing that observation

    L::Float64
    U::Float64
    d::Int          # depth

    children::UnitRange{Int64}
end

function BeliefNode(b,ind::Int,pind::Int,oi::Int,po::Float64,L::Float64,U::Float64,d::Int)
    return BeliefNode(b, ind, pind, oi, po, L, U, d, 0:0)
end

mutable struct Graph
    action_nodes::Vector{ActionNode}
    belief_nodes::Vector{BeliefNode}

    na::Int     # number of action nodes
    nb::Int     # number of belief nodes

    root_ind::Int
    fringe_list::Set{BeliefNode}

    df::Float64     # discount factor

    # constructor
    function Graph(df::Real)
        new(ActionNode[], BeliefNode[], 0, 0, 1, Set{BeliefNode}(), df)
    end
end

function clear_graph!(G::Graph)
    G.action_nodes = ActionNode[]
    G.belief_nodes = BeliefNode[]
    G.na = 0
    G.nb = 0
    G.root_ind = 1
    G.fringe_list = Set{BeliefNode}()
end

isroot(G::Graph, bn::BeliefNode) = G.root_ind == bn.ind

function add_node(G::Graph, an::ActionNode)
    push!(G.action_nodes, an)
    G.na += 1
end
function add_node(G::Graph, bn::BeliefNode)
    push!(G.belief_nodes, bn)   # add new node to list of belief nodes
    push!(G.fringe_list, bn)    # add new node to fringe list
    G.nb += 1                   # length of G.belief_nodes increases by 1
end

parent_node(G::Graph, bn::BeliefNode) = G.action_nodes[bn.pind]
parent_node(G::Graph, an::ActionNode) = G.belief_nodes[an.pind]

remove_from_fringe(G::Graph, bn::BeliefNode) = delete!(G.fringe_list, bn)
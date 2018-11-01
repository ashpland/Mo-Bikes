//
//  Functional.swift
//  Mo-Bikes
//
//  Created by Andrew on 2018-10-16.
//  Copyright © 2018 hearthedge. All rights reserved.
//

//
//  Operators:
//      |>      Forward Application: passes value lhs to function rhs
//      >>>     Forward Composition: composes function (A) -> B with function (B) -> C to create new function (A) -> C
//      <>      Single Type Composition: composes function (A) -> A with function (A) -> A to create new function (A) -> A
//      &>     InOut Forward Application: passes inout value lhs to function rhs
//

// MARK: Function application and composition

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator |>: ForwardApplication

@discardableResult func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

func <> <A>(
    f: @escaping (A) -> A,
    g: @escaping (A) -> A)
    -> ((A) -> A) {

        return f >>> g
}

// MARK: - Function Manipulation

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}

func zurry<A>(_ f: () -> A) -> A {
    return f()
}

// MARK: - Mapping

func map<Element, ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> ([Element]) -> [ElementOfResult] {
    return { $0.map(transform) }
}

func compactMap<Element, ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult?) -> ([Element]) -> [ElementOfResult] {
    return { $0.compactMap(transform) }
}

func flattenArrays<Element>(_ sequence: [[Element]]) -> [Element] {
    return sequence.flatMap { $0 }
}

// MARK: - Setters

func set<Root, Element>(_ kp: WritableKeyPath<Root, Element>, to value: Element) -> (inout Root) -> Void {
    return { object in
        object[keyPath: kp] = value
    }
}

func set<Root, Element>(_ kp: WritableKeyPath<Root, Element>, on object: Root) -> (Element) -> Element {
    return { value in
        var object = object
        object[keyPath: kp] = value
        return value
    }
}

// MARK: - Inout

infix operator &>: ForwardApplication

func &> <A>(a: inout A, f: (inout A) -> Void) {
    f(&a)
}

func &> <A>(a: A?, f: (inout A) -> Void) {
    if var a = a {
        f(&a)
    }
}

@discardableResult func &> <A, B>(a: inout A, f: (inout A) -> B) -> B {
    return f(&a)
}

func <> <A>(
    f: @escaping (inout A) -> Void,
    g: @escaping (inout A) -> Void)
    -> ((inout A) -> Void) {

        return { a in
            f(&a)
            g(&a)
        }
}

func >>> <A, B>(f: @escaping (A) -> B, g: @escaping (inout B) -> B) -> ((A) -> B) {
    return { a in
        var b = f(a)
        return g(&b)
    }
}

func >>> <A>(f: @escaping (inout A) -> A, g: @escaping (inout A) -> A) -> ((inout A) -> A) {
    return { a in
        var b = f(&a)
        return g(&b)
    }
}

func map<Element: AnyObject, ElementOfResult>(_ transform: @escaping (inout Element) -> ElementOfResult) -> ([Element]) -> [ElementOfResult] {
    return { elementArray in
        return elementArray.map {
            var element = $0
            return transform(&element)
        }
    }
}

// MARK: - Overloads for throwing functions

func |> <A, B>(a: A, f: (A) throws -> B) throws -> B {
    return try f(a)
}

func >>> <A, B, C>(f: @escaping (A) throws -> B, g: @escaping (B) -> C) -> ((A) throws -> C) {
    return { a in
        try g(f(a))
    }
}

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) throws -> C) -> ((A) throws -> C) {
    return { a in
        try g(f(a))
    }
}

func >>> <A, B, C>(f: @escaping (A) throws -> B, g: @escaping (B) throws -> C) -> ((A) throws -> C) {
    return { a in
        try g(f(a))
    }
}

@discardableResult func &> <A, B>(a: inout A, f: (inout A) throws -> B) throws -> B {
    return try f(&a)
}

func <> <A>(
    f: @escaping (inout A) throws -> Void,
    g: @escaping (inout A) -> Void)
    -> ((inout A) throws -> Void) {

        return { a in
            try f(&a)
            g(&a)
        }
}

func <> <A>(
    f: @escaping (inout A) -> Void,
    g: @escaping (inout A) throws -> Void)
    -> ((inout A) throws -> Void) {

        return { a in
            f(&a)
            try g(&a)
        }
}

func <> <A>(
    f: @escaping (inout A) throws -> Void,
    g: @escaping (inout A) throws -> Void)
    -> ((inout A) throws -> Void) {

        return { a in
            try f(&a)
            try g(&a)
        }
}

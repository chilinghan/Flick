//
//  ChartContent.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/23/24.
//

import SwiftUI
import Charts

struct ChartContent: View {
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color("LightOr").opacity(0.8),
                    Color("LightOr").opacity(0.3),
                   // Color.pink.opacity(0.01),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
            
        )
    }
    
    var data = [
        ChartView(
            X1: 1,
            Y1: 4),
        
        ChartView(
            X1: 2,
            Y1: 9),
        
        ChartView(
            X1: 3,
            Y1: -10),
        
        ChartView(
            X1: 4,
            Y1: 3),
        
        ChartView(
            X1: 5,
            Y1: 10),
        
        ChartView(
            X1: 6,
            Y1: -5),
        
        ChartView(
            X1: 7,
            Y1: -1),
        
        ChartView(
            X1: 8,
            Y1: -6),
        
        ChartView(
            X1: 9,
            Y1: -7),
        
        ChartView(
            X1: 10,
            Y1: 4),
        
        ChartView(
            X1: 11,
            Y1: 2),
        
        ChartView(
            X1: 12,
            Y1: 6),
        
        ChartView(
            X1: 13,
            Y1: 5),
        
        ChartView(
            X1: 14,
            Y1: -4),
        
        ChartView(
            X1: 15,
            Y1: -8),
        
        ChartView(
            X1: 16,
            Y1: 5),
        
        ChartView(
            X1: 17,
            Y1: 5),
        
        ChartView(
            X1: 18,
            Y1: 9),
        
        ChartView(
            X1: 19,
            Y1: 10),
        
        ChartView(
            X1: 20,
            Y1: 7),
        
        ChartView(
            X1: 21,
            Y1: 6),
        
        ChartView(
            X1: 22,
            Y1: 3),
        
        ChartView(
            X1: 23,
            Y1: 8),
        
        ChartView(
            X1: 24,
            Y1: -9),
        
        ChartView(
            X1: 25,
            Y1: 7),
        
        ChartView(
            X1: 26,
            Y1: 1),
        
        ChartView(
            X1: 27,
            Y1: -3),
        
        ChartView(
            X1: 28,
            Y1: 1),
        
        ChartView(
            X1: 29,
            Y1: 7),
        
        ChartView(
            X1: 30,
            Y1: -2),
    ]
    
    var body: some View {
        Chart {
            ForEach(data) { d in
                AreaMark(x: .value("X1", d.X1), y: .value("Y1", d.Y1))
                    .foregroundStyle(gradientColor)
                  // .frame(width: 100, height: 100)
                   // AxisMarks(position: .leading)
                  /*  .chartYAxis {
                        AxisMarks(position: .leading)
                    } */
            }
        }
        .frame(height: 300)
        .chartYAxis {
            AxisMarks(position: .leading)
       
                
        }
    }
}

#Preview {
    ChartContent()
}


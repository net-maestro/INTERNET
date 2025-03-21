<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Таблица с цветами для групп</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 8px;
            text-align: left;
            border: 1px solid #ddd;
        }

        .group-1 {
            background-color: #b3d9ff; /* Светло-голубой */
        }

        .group-2 {
            background-color: #b3ffb3; /* Светло-зеленый */
        }

        .group-3 {
            background-color: #ffffb3; /* Светло-желтый */
        }

        .group-4 {
            background-color: #ffb3d9; /* Светло-розовый */
        }

        .group-5 {
            background-color: #ffcc99; /* Светло-оранжевый */
        }

        .group-6 {
            background-color: #e6b3ff; /* Светло-пурпурный */
        }

        .group-7 {
            background-color: #99ccff; /* Светло-синий */
        }

        .group-8 {
            background-color: #d9b3ff; /* Светло-фиолетовый */
        }

        .group-9 {
            background-color: #b3e0ff; /* Светло-голубой */
        }

        .group-10 {
            background-color: #b3ffb3; /* Светло-зеленый */
        }

        .group-11 {
            background-color: #ffffb3; /* Светло-желтый */
        }

        .group-12 {
            background-color: #ffb3d9; /* Светло-розовый */
        }

        .group-13 {
            background-color: #ffcc99; /* Светло-оранжевый */
        }
    </style>
</head>
<body>
    <table>
        <thead>
            <tr>
                <th>Group Name</th>
                <th>VLAN Prefix</th>
                <th>Network Address</th>
                <th>External-IPs</th>
            </tr>
        </thead>
        <tbody>
            <!-- Group 1 -->
            <tr class="group-1">
                <td><strong>Group 1: 10a</strong></td>
                <td>10ap1vl111</td>
                <td>172.16.11.0/24</td>
                <td>146.121.101.1-146.121.101.4</td>
            </tr>
            <tr class="group-1">
                <td></td>
                <td>10ap2vl112</td>
                <td>172.16.12.0/24</td>
                <td></td>
            </tr>
            <tr class="group-1">
                <td></td>
                <td>10ap03vl13</td>
                <td>172.16.13.0/24</td>
                <td></td>
            </tr>
            <tr class="group-1">
                <td></td>
                <td>10ap4vl114</td>
                <td>172.16.14.0/24</td>
                <td></td>
            </tr>
            <tr class="group-1">
                <td></td>
                <td>10ap5vl115</td>
                <td>172.16.15.0/24</td>
                <td></td>
            </tr>
            <tr class="group-1">
                <td></td>
                <td>10ap6vl116</td>
                <td>172.16.16.0/24</td>
                <td></td>
            </tr>

            <!-- Group 2 -->
            <tr class="group-2">
                <td><strong>Group 2: 10b</strong></td>
                <td>10bp1vl121</td>
                <td>172.16.21.0/24</td>
                <td>146.121.101.5-146.121.101.7</td>
            </tr>
            <tr class="group-2">
                <td></td>
                <td>10bp2vl122</td>
                <td>172.16.22.0/24</td>
                <td></td>
            </tr>
            <tr class="group-2">
                <td></td>
                <td>10bp3vl123</td>
                <td>172.16.23.0/24</td>
                <td></td>
            </tr>
            <tr class="group-2">
                <td></td>
                <td>10bp4vl124</td>
                <td>172.16.24.0/24</td>
                <td></td>
            </tr>
            <tr class="group-2">
                <td></td>
                <td>10bp5vl125</td>
                <td>172.16.25.0/24</td>
                <td></td>
            </tr>

            <!-- Group 3 -->
            <tr class="group-3">
                <td><strong>Group 3: 10v</strong></td>
                <td>10vp1vl131</td>
                <td>172.16.31.0/24</td>
                <td>146.121.101.8-146.121.101.9</td>
            </tr>
            <tr class="group-3">
                <td></td>
                <td>10vp2vl132</td>
                <td>172.16.32.0/24</td>
                <td></td>
            </tr>
            <tr class="group-3">
                <td></td>
                <td>10vp3vl133</td>
                <td>172.16.33.0/24</td>
                <td></td>
            </tr>

            <!-- Group 4 -->
            <tr class="group-4">
                <td><strong>Group 4: 10g</strong></td>
                <td>10gp5vl145</td>
                <td>172.16.45.0/24</td>
                <td>146.121.101.10-146.121.101.12</td>
            </tr>
            <tr class="group-4">
                <td></td>
                <td>10gp4vl144</td>
                <td>172.16.44.0/24</td>
                <td></td>
            </tr>
            <tr class="group-4">
                <td></td>
                <td>10gp3vl143</td>
                <td>172.16.43.0/24</td>
                <td></td>
            </tr>
            <tr class="group-4">
                <td></td>
                <td>10gp2vl142</td>
                <td>172.16.42.0/24</td>
                <td></td>
            </tr>
            <tr class="group-4">
                <td></td>
                <td>10gp1vl141</td>
                <td>172.16.41.0/24</td>
                <td></td>
            </tr>

            <!-- Group 5 -->
            <tr class="group-5">
                <td><strong>Group 5: 10d</strong></td>
                <td>10dp1vl151</td>
                <td>172.16.51.0/24</td>
                <td>146.121.101.13-146.121.101.15</td>
            </tr>
            <tr class="group-5">
                <td></td>
                <td>10dp2vl152</td>
                <td>172.16.52.0/24</td>
                <td></td>
            </tr>
            <tr class="group-5">
                <td></td>
                <td>10dp3vl153</td>
                <td>172.16.53.0/24</td>
                <td></td>
            </tr>
            <tr class="group-5">
                <td></td>
                <td>10dp4vl154</td>
                <td>172.16.54.0/24</td>
                <td></td>
            </tr>

            <!-- Group 6 -->
            <tr class="group-6">
                <td><strong>Group 6: 14</strong></td>
                <td>14p3vl163</td>
                <td>172.16.63.0/24</td>
                <td>146.121.101.16-146.121.101.17</td>
            </tr>
            <tr class="group-6">
                <td></td>
                <td>14p4vl164</td>
                <td>172.16.64.0/24</td>
                <td></td>
            </tr>
            <tr class="group-6">
                <td></td>
                <td>14p5vl165</td>
                <td>172.16.65.0/24</td>
                <td></td>
            </tr>
            <tr class="group-6">
                <td></td>
                <td>14p2vl162</td>
                <td>172.16.62.0/24</td>
                <td></td>
            </tr>
            <tr class="group-6">
                <td></td>
                <td>14p1vl161</td>
                <td>172.16.61.0/24</td>
                <td></td>
            </tr>

            <!-- Group 7 -->
            <tr class="group-7">
                <td><strong>Group 7: 20</strong></td>
                <td>20p1vl171</td>
                <td>172.16.71.0/24</td>
                <td>146.121.101.18-146.121.101.21</td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p2vl172</td>
                <td>172.16.72.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p3vl173</td>
                <td>172.16.73.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p4vl174</td>
                <td>172.16.74.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p5vl175</td>
                <td>172.16.75.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p6vl176</td>
                <td>172.16.76.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p7vl177</td>
                <td>172.16.77.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p8vl178</td>
                <td>172.16.78.0/24</td>
                <td></td>
            </tr>
            <tr class="group-7">
                <td></td>
                <td>20p9vl179</td>
                <td>172.16.79.0/24</td>
                <td></td>
            </tr>

            <!-- Group 8 -->
            <tr class="group-8">
                <td><strong>Group 8: bar</strong></td>
                <td>bar1vl91</td>
                <td>172.16.191.0/24</td>
                <td>146.121.101.22-146.121.101.23</td>
            </tr>
            <tr class="group-8">
                <td></td>
                <td>bar2vl92</td>
                <td>172.16.192.0/24</td>
                <td></td>
            </tr>
            <tr class="group-8">
                <td></td>
                <td>bar3vl93</td>
                <td>172.16.193.0/24</td>
                <td></td>
            </tr>
            <tr class="group-8">
                <td></td>
                <td>bar4vl94</td>
                <td>172.16.194.0/24</td>
                <td></td>
            </tr>

            <!-- Group 9 -->
            <tr class="group-9">
                <td><strong>Group 9: ka</strong></td>
                <td>ka9vl71</td>
                <td>172.16.81.0/24</td>
                <td>146.121.101.24-146.121.101.25</td>
            </tr>
            <tr class="group-9">
                <td></td>
                <td>ka1avl72</td>
                <td>172.16.82.0/24</td>
                <td></td>
            </tr>
            <tr class="group-9">
                <td></td>
                <td>ka11avl73</td>
                <td>172.16.83.0/24</td>
                <td></td>
            </tr>
            <tr class="group-9">
                <td></td>
                <td>ka9vl71</td>
                <td>172.16.80.0/24</td>
                <td></td>
            </tr>

            <!-- Group 10 -->
            <tr class="group-10">
                <td><strong>Group 10: pon</strong></td>
                <td>pon1vl1001</td>
                <td>172.16.200.0/23</td>
                <td>146.121.101.26-146.121.101.27</td>
            </tr>
            <tr class="group-10">
                <td></td>
                <td>pon2vl1002</td>
                <td>172.16.202.0/23</td>
                <td></td>
            </tr>

            <!-- Group 11 -->
            <tr class="group-11">
                <td><strong>Group 11: she</strong></td>
                <td>she21vl21</td>
                <td>172.16.121.0/24</td>
                <td>146.121.101.28-146.121.101.29</td>
            </tr>
            <tr class="group-11">
                <td></td>
                <td>she21vl21</td>
                <td>172.16.121.0/24</td>
                <td></td>
            </tr>
            <tr class="group-11">
                <td></td>
                <td>she22vl22</td>
                <td>172.16.122.0/24</td>
                <td></td>
            </tr>

            <!-- Group 12 -->
            <tr class="group-12">
                <td><strong>Group 12: ns</strong></td>
                <td>ns9vl50</td>
                <td>172.16.250.0/23</td>
                <td>146.121.101.30-146.121.101.31</td>
            </tr>
            <tr class="group-12">
                <td></td>
                <td>ns1vl1000</td>
                <td>172.16.251.0/23</td>
                <td></td>
            </tr>
            <tr class="group-12">
                <td></td>
                <td>ns2vl1000</td>
                <td>172.16.252.0/23</td>
                <td></td>
            </tr>

            <!-- Group 13 -->
            <tr class="group-13">
                <td><strong>Group 13: se</strong></td>
                <td>se9vl100</td>
                <td>172.16.300.0/23</td>
                <td>146.121.101.32-146.121.101.33</td>
            </tr>
            <tr class="group-13">
                <td></td>
                <td>se1vl1001</td>
                <td>172.16.301.0/23</td>
                <td></td>
            </tr>
            <tr class="group-13">
                <td></td>
                <td>se2vl1002</td>
                <td>172.16.302.0/23</td>
                <td></td>
            </tr>
        </tbody>
    </table>
</body>
</html>

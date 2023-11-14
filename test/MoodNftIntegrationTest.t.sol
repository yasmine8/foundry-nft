//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";

contract MoodNftIntegrationTest is Test {
    DeployMoodNft deployer;
    address USER = makeAddr("user");

    MoodNft moodNft;

    string public constant BASE_URI = "data:application/json;base64,";

    string public constant SAD_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyB2ZXJzaW9uPSIxLjEiIGlkPSJDYXBhXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIKICAgIHk9IjBweCIgdmlld0JveD0iMCAwIDQ5MCA0OTAiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDQ5MCA0OTA7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4KICAgIDxnPgogICAgICAgIDxwYXRoIGQ9Ik0xMTkuMzksMzQwLjAxNWwxOC4zMzMsMjQuNTM5YzQuNDExLTMuMjYsMTA4Ljc3My03OC45MSwyMTQuNTg0LDBMMzcwLjYxLDM0MAoJCUMyNDYuMjExLDI0Ny4xODMsMTIwLjY0NiwzMzkuMDg4LDExOS4zOSwzNDAuMDE1eiIgLz4KICAgICAgICA8cGF0aCBkPSJNMTU5Ljc0NCwyMzYuMDk2YzIzLjU1LDAsNDIuNjQyLTE5LjA5Miw0Mi42NDItNDIuNjQyYzAtMTAuNDYxLTMuOTEzLTE5LjkxNS0xMC4xNjQtMjcuMzM0aDI5LjQwNXYtMzAuNjI1SDk3Ljg1NnYzMC42MjUKCQloMjkuNDA5Yy02LjI1MSw3LjQxOS0xMC4xNjQsMTYuODczLTEwLjE2NCwyNy4zMzRDMTE3LjEwMiwyMTcuMDA0LDEzNi4xOTQsMjM2LjA5NiwxNTkuNzQ0LDIzNi4wOTZ6IiAvPgogICAgICAgIDxwYXRoIGQ9Ik0yNjguMzcyLDE2Ni4xMmgzMS41MDRjLTYuMjUxLDcuNDE5LTEwLjE2NCwxNi44NzMtMTAuMTY0LDI3LjMzNGMwLDIzLjU1LDE5LjA5MSw0Mi42NDIsNDIuNjQyLDQyLjY0MgoJCWMyMy41NSwwLDQyLjY0MS0xOS4wOTIsNDIuNjQxLTQyLjY0MmMwLTEwLjQ2MS0zLjkxMy0xOS45MTUtMTAuMTY0LTI3LjMzNGgyNy4zMjd2LTMwLjYyNUgyNjguMzcyVjE2Ni4xMnoiIC8+CiAgICAgICAgPHBhdGggZD0iTTQyMC45MTQsMEg2OS4wODZDMzAuOTk5LDAsMCwzMC45OTksMCw2OS4wODZ2MzUxLjgyOUMwLDQ1OS4wMDEsMzAuOTk5LDQ5MCw2OS4wODYsNDkwaDM1MS44MjkKCQlDNDU5LjAwMSw0OTAsNDkwLDQ1OS4wMDEsNDkwLDQyMC45MTRWNjkuMDg2QzQ5MCwzMC45OTksNDU5LjAwMSwwLDQyMC45MTQsMHogTTQ1OS4zNzUsNDIwLjkxNAoJCWMwLDIxLjIwNC0xNy4yNTcsMzguNDYxLTM4LjQ2MSwzOC40NjFINjkuMDg2Yy0yMS4yMDQsMC0zOC40NjEtMTcuMjU3LTM4LjQ2MS0zOC40NjFWNjkuMDg2YzAtMjEuMjA0LDE3LjI1Ni0zOC40NjEsMzguNDYxLTM4LjQ2MQoJCWgzNTEuODI5YzIxLjIwNCwwLDM4LjQ2MSwxNy4yNTcsMzguNDYxLDM4LjQ2MVY0MjAuOTE0eiIgLz4KICAgIDwvZz4KPC9zdmc+";

    string public constant HAPPY_SVG_IMAGE_URI =
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICAgIDxwYXRoCiAgICAgICAgZD0iTTE1IDIyLjc1SDlDMy41NyAyMi43NSAxLjI1IDIwLjQzIDEuMjUgMTVWOUMxLjI1IDMuNTcgMy41NyAxLjI1IDkgMS4yNUgxNUMyMC40MyAxLjI1IDIyLjc1IDMuNTcgMjIuNzUgOVYxNUMyMi43NSAyMC40MyAyMC40MyAyMi43NSAxNSAyMi43NVpNOSAyLjc1QzQuMzkgMi43NSAyLjc1IDQuMzkgMi43NSA5VjE1QzIuNzUgMTkuNjEgNC4zOSAyMS4yNSA5IDIxLjI1SDE1QzE5LjYxIDIxLjI1IDIxLjI1IDE5LjYxIDIxLjI1IDE1VjlDMjEuMjUgNC4zOSAxOS42MSAyLjc1IDE1IDIuNzVIOVoiCiAgICAgICAgZmlsbD0iIzAwMDAwMCIgLz4KICAgIDxwYXRoCiAgICAgICAgZD0iTTE1LjUgMTAuNUMxNC4yNiAxMC41IDEzLjI1IDkuNDkgMTMuMjUgOC4yNUMxMy4yNSA3LjAxIDE0LjI2IDYgMTUuNSA2QzE2Ljc0IDYgMTcuNzUgNy4wMSAxNy43NSA4LjI1QzE3Ljc1IDkuNDkgMTYuNzQgMTAuNSAxNS41IDEwLjVaTTE1LjUgNy41QzE1LjA5IDcuNSAxNC43NSA3Ljg0IDE0Ljc1IDguMjVDMTQuNzUgOC42NiAxNS4wOSA5IDE1LjUgOUMxNS45MSA5IDE2LjI1IDguNjYgMTYuMjUgOC4yNUMxNi4yNSA3Ljg0IDE1LjkxIDcuNSAxNS41IDcuNVoiCiAgICAgICAgZmlsbD0iIzAwMDAwMCIgLz4KICAgIDxwYXRoCiAgICAgICAgZD0iTTguNSAxMC41QzcuMjYgMTAuNSA2LjI1IDkuNDkgNi4yNSA4LjI1QzYuMjUgNy4wMSA3LjI2IDYgOC41IDZDOS43NCA2IDEwLjc1IDcuMDEgMTAuNzUgOC4yNUMxMC43NSA5LjQ5IDkuNzQgMTAuNSA4LjUgMTAuNVpNOC41IDcuNUM4LjA5IDcuNSA3Ljc1IDcuODQgNy43NSA4LjI1QzcuNzUgOC42NiA4LjA5IDkgOC41IDlDOC45MSA5IDkuMjUgOC42NiA5LjI1IDguMjVDOS4yNSA3Ljg0IDguOTEgNy41IDguNSA3LjVaIgogICAgICAgIGZpbGw9IiMwMDAwMDAiIC8+CiAgICA8cGF0aAogICAgICAgIGQ9Ik0xMiAxOS40NUM5LjEgMTkuNDUgNi43NSAxNy4wOSA2Ljc1IDE0LjJDNi43NSAxMy4yOSA3LjQ5IDEyLjU1IDguNCAxMi41NUgxNS42QzE2LjUxIDEyLjU1IDE3LjI1IDEzLjI5IDE3LjI1IDE0LjJDMTcuMjUgMTcuMDkgMTQuOSAxOS40NSAxMiAxOS40NVpNOC40IDE0LjA1QzguMzIgMTQuMDUgOC4yNSAxNC4xMiA4LjI1IDE0LjJDOC4yNSAxNi4yNyA5LjkzIDE3Ljk1IDEyIDE3Ljk1QzE0LjA3IDE3Ljk1IDE1Ljc1IDE2LjI3IDE1Ljc1IDE0LjJDMTUuNzUgMTQuMTIgMTUuNjggMTQuMDUgMTUuNiAxNC4wNUg4LjRWMTQuMDVaIgogICAgICAgIGZpbGw9IiMwMDAwMDAiIC8+Cjwvc3ZnPg==";

    string public constant SAD_SVG_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBEOTRiV3dnZG1WeWMybHZiajBpTVM0d0lpQnpkR0Z1WkdGc2IyNWxQU0p1YnlJL1BnbzhjM1puSUhkcFpIUm9QU0l4TURJMGNIZ2lJR2hsYVdkb2REMGlNVEF5TkhCNElpQjJhV1YzUW05NFBTSXdJREFnTVRBeU5DQXhNREkwSWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGdvZ0lDQWdQSEJoZEdnZ1ptbHNiRDBpSXpNek15SUtJQ0FnSUNBZ0lDQmtQU0pOTlRFeUlEWTBRekkyTkM0MklEWTBJRFkwSURJMk5DNDJJRFkwSURVeE1uTXlNREF1TmlBME5EZ2dORFE0SURRME9DQTBORGd0TWpBd0xqWWdORFE0TFRRME9GTTNOVGt1TkNBMk5DQTFNVElnTmpSNmJUQWdPREl3WXkweU1EVXVOQ0F3TFRNM01pMHhOall1Tmkwek56SXRNemN5Y3pFMk5pNDJMVE0zTWlBek56SXRNemN5SURNM01pQXhOall1TmlBek56SWdNemN5TFRFMk5pNDJJRE0zTWkwek56SWdNemN5ZWlJZ0x6NEtJQ0FnSUR4d1lYUm9JR1pwYkd3OUlpTkZOa1UyUlRZaUNpQWdJQ0FnSUNBZ1pEMGlUVFV4TWlBeE5EQmpMVEl3TlM0MElEQXRNemN5SURFMk5pNDJMVE0zTWlBek56SnpNVFkyTGpZZ016Y3lJRE0zTWlBek56SWdNemN5TFRFMk5pNDJJRE0zTWkwek56SXRNVFkyTGpZdE16Y3lMVE0zTWkwek56SjZUVEk0T0NBME1qRmhORGd1TURFZ05EZ3VNREVnTUNBd0lERWdPVFlnTUNBME9DNHdNU0EwT0M0d01TQXdJREFnTVMwNU5pQXdlbTB6TnpZZ01qY3lhQzAwT0M0eFl5MDBMaklnTUMwM0xqZ3RNeTR5TFRndU1TMDNMalJETmpBMElEWXpOaTR4SURVMk1pNDFJRFU1TnlBMU1USWdOVGszY3kwNU1pNHhJRE01TGpFdE9UVXVPQ0E0T0M0Mll5MHVNeUEwTGpJdE15NDVJRGN1TkMwNExqRWdOeTQwU0RNMk1HRTRJRGdnTUNBd0lERXRPQzA0TGpSak5DNDBMVGcwTGpNZ056UXVOUzB4TlRFdU5pQXhOakF0TVRVeExqWnpNVFUxTGpZZ05qY3VNeUF4TmpBZ01UVXhMalpoT0NBNElEQWdNQ0F4TFRnZ09DNDBlbTB5TkMweU1qUmhORGd1TURFZ05EZ3VNREVnTUNBd0lERWdNQzA1TmlBME9DNHdNU0EwT0M0d01TQXdJREFnTVNBd0lEazJlaUlnTHo0S0lDQWdJRHh3WVhSb0lHWnBiR3c5SWlNek16TWlDaUFnSUNBZ0lDQWdaRDBpVFRJNE9DQTBNakZoTkRnZ05EZ2dNQ0F4SURBZ09UWWdNQ0EwT0NBME9DQXdJREVnTUMwNU5pQXdlbTB5TWpRZ01URXlZeTA0TlM0MUlEQXRNVFUxTGpZZ05qY3VNeTB4TmpBZ01UVXhMalpoT0NBNElEQWdNQ0F3SURnZ09DNDBhRFE0TGpGak5DNHlJREFnTnk0NExUTXVNaUE0TGpFdE55NDBJRE11TnkwME9TNDFJRFExTGpNdE9EZ3VOaUE1TlM0NExUZzRMalp6T1RJZ016a3VNU0E1TlM0NElEZzRMalpqTGpNZ05DNHlJRE11T1NBM0xqUWdPQzR4SURjdU5FZzJOalJoT0NBNElEQWdNQ0F3SURndE9DNDBRelkyTnk0MklEWXdNQzR6SURVNU55NDFJRFV6TXlBMU1USWdOVE16ZW0weE1qZ3RNVEV5WVRRNElEUTRJREFnTVNBd0lEazJJREFnTkRnZ05EZ2dNQ0F4SURBdE9UWWdNSG9pSUM4K0Nqd3ZjM1puUGc9PSJ9";

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testViewTokenUriIntegration() public {
        vm.prank(USER);
        moodNft.mintNft();

        console.log("The User's URI is: ", moodNft.tokenURI(0));
    }

    function testFlipTokenToSad() public {
        vm.startBroadcast(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopBroadcast();

        console.log(moodNft.tokenURI(0));

        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(abi.encodePacked(SAD_SVG_URI))
        );
    }
}
#!/usr/bin/env node
import 'source-map-support/register'
import { EngDevAccount, EngProdAccount, GitFlowDeploymentPipeline, Region } from '@ginger.io/cdk-constructs'
import { App } from 'aws-cdk-lib'
import { FlutterWebStage } from '../lib/FlutterWebStage'
import { NodeVersion } from "@ginger.io/cdk-constructs/dist/pipelines/types";

const app = new App()

new GitFlowDeploymentPipeline(app, {
  gitRepo: 'mini-flutter-web-client',
  serviceName: 'FlutterWebScheduler',
  nodeVersion: NodeVersion.NODE_16_X,
  deploymentTargets: [
    {
      stage: FlutterWebStage,
      gitBranch: 'develop',
      account: EngDevAccount,
      region: Region.US_EAST_1,

      // TODO: configure codebuild if you want
      includeBuildAndTestStep: false
    },
    {
      stage: FlutterWebStage,
      gitBranch: 'master',
      account: EngProdAccount,
      region: Region.US_EAST_1,

      // TODO: configure codebuild if you want
      includeBuildAndTestStep: false
    }
  ]
})
